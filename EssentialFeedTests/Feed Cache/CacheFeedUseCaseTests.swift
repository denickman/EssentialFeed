//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 10.10.2024.
//

import XCTest
import EssentialFeed

enum Result {
    case success
    case failure(Error)
}

// Эти тесты проверяют правильность работы use case для кэширования фида (CacheFeedUseCase)

final class CacheFeedUseCaseTests: XCTestCase {
    
    // Этот тест проверяет, что при создании экземпляра LocalFeedLoader не отправляются никакие сообщения в FeedStoreSpy. То есть проверяется, что объект инициализируется корректно и не выполняет лишних действий (например, не взаимодействует с хранилищем данных при создании).
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // Этот тест проверяет, что при вызове метода save (сохранение нового фида) сначала запрашивается удаление предыдущего кеша через сообщение .deleteCacheFeed. Перед тем как сохранить новые данные, всегда сначала нужно удалить старый кеш.
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    // Тест проверяет, что если удаление кеша завершилось с ошибкой, система не пытается вставить новый фид в кеш. То есть если удаление старых данных не удалось, дальнейшая работа должна остановиться.
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().models) { _ in  }
        
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    //  Этот тест проверяет, что если удаление кеша прошло успешно, должен вставляться новый фид с текущей меткой времени. Метод save сначала удаляет старый кеш, а затем вставляет новые данные.
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccesfulDeletion() {
        let timestamp = Date()
        
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.local, timestamp)])
    }
    
    // Тест проверяет, что если при удалении кеша произошла ошибка, метод save завершится с этой ошибкой и не выполнит сохранение.
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    // Этот тест проверяет, что если при вставке нового фида произошла ошибка, метод save также завершится ошибкой. Даже если удаление кеша прошло успешно, ошибка на этапе вставки должна обрабатываться.
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    // Тест проверяет, что если и удаление старого кеша, и вставка нового фида прошли успешно, метод save завершится успешно.
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    // Этот тест проверяет, что если объект LocalFeedLoader был деинициализирован, ошибки удаления кеша не должны быть доставлены. Это важно для предотвращения утечек памяти или ненужных операций после освобождения объекта.
    func test_save_doesNotDeliverDeletionError_afterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        
        sut?.save(uniqueImageFeed().models, completion: { result in
            receivedResults.append(result)
        })
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // Аналогичный предыдущему тест, но проверяется, что ошибки вставки фида не доставляются, если объект LocalFeedLoader был деинициализирован. Это гарантирует, что работа прекращается после деинициализации объекта, и ошибки не передаются.
    func test_save_doesNotDeliverInsertionError_afterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        
        sut?.save(uniqueImageFeed().models, completion: { result in
            if case let .failure(error) = result {
                receivedResults.append(error)
            }
#warning("Check with commits, does not work")
            //            receivedResults.append(result)
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toCompleteWithError exptectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        
        sut.save(uniqueImageFeed().models) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
#warning("Check with commits, does not work")
            //            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp])
        XCTAssertEqual(receivedError as? NSError, exptectedError, file: file, line: line)
    }
}
