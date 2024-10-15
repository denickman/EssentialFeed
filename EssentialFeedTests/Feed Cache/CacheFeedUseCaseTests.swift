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

final class CacheFeedUseCaseTests: XCTestCase {
    
    
    // Тест проверяет, что при создании экземпляра LocalFeedLoader не отправляется никаких сообщений в хранилище (FeedStoreSpy).
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // Тест проверяет, что при вызове метода save, перед тем как сохранить новые данные, удаляется предыдущий кеш
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    // Если удаление кеша завершилось с ошибкой, метод save не должен пытаться вставить новый фид.
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().models) { _ in  }
        
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    //  Если удаление кеша прошло успешно, нужно вставить новый кеш с текущей меткой времени.
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccesfulDeletion() {
        let timestamp = Date()
        
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.local, timestamp)])
    }
    
    // Эти 2 теста проверяют, что сохранение завершится ошибкой, если во время удаления или вставки произошла ошибка.
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    // Проверяется успешное сохранение фида в случае успешного удаления и вставки.
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    // Тест проверяет, что после удаления экземпляра LocalFeedLoader не должно быть доставки ошибок, связанных с удалением кеша.
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
    
    // Аналогичный тест для ошибки вставки после деинициализации LocalFeedLoader.
    func test_save_doesNotDeliverInsertionError_afterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        
        sut?.save(uniqueImageFeed().models, completion: { result in
            receivedResults.append(result)
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
        
        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp])
        XCTAssertEqual(receivedError as? NSError, exptectedError, file: file, line: line)
    }
}
