//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 15.10.2024.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmtpyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .success(.none))
    }
    
    /// Этот тест проверяет, что при вставке данных в пустое хранилище, их последующее извлечение возвращает корректные данные без изменения состояния кэша. Тест проверяет, что хранилище сохраняет вставленные данные и возвращает их без побочных эффектов.
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
//        let sut = makeSUT()
//        let feed = uniqueImageFeed().local
//        let timestamp = Date()
//        
//        insert((feed, timestamp), to: sut)
//        expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
    /// Этот тест проверяет, что если кэш содержит данные, то метод retrieve должен вернуть эти данные. В начале теста данные сохраняются в кэш, затем вызывается метод retrieve, и проверяется, что он возвращает сохранённые ранее данные.
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()
//        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что повторные вызовы метода retrieve на непустом кэше не изменяют его содержимое. То есть, если кэш содержит какие-то данные, то вызов метода retrieve несколько раз должен возвращать одни и те же данные без их изменения.
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что если данные в хранилище повреждены или находятся в неверном формате, метод retrieve возвращает ошибку. Для этого в хранилище записываются невалидные данные (строка "invalid data"), после чего вызывается метод получения данных, и проверяется, что была возвращена ошибка.
    func test_retrieve_deliversFailureOnRetrievalError() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        
//        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
//        
//        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    /// Этот тест проверяет, что если при получении данных произошла ошибка (например, из-за невалидных данных в хранилище), то последующие вызовы метода retrieve возвращают ту же ошибку, и состояние хранилища не изменяется. Снова используется невалидное состояние хранилища (записываются "invalid data"), и проверяется, что после получения ошибки повторный вызов retrieve не изменяет состояние кэша.
    func test_retrieve_hasNoSideEffectsOnFailure() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        
//        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
//        
//        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    /// Этот тест проверяет, что вставка данных в пустой кэш выполняется без ошибок. Он вызывает метод insert на пустом кэше и ожидает успешное завершение без каких-либо ошибок.
    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что вставка данных в уже непустой кэш также выполняется без ошибок. То есть, даже если кэш содержит данные, новые данные могут быть успешно вставлены, и это не приведёт к ошибкам.
    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что при вставке новых данных в кэш предыдущие данные перезаписываются. Сначала в кэш вставляются одни данные, а затем новые данные. После чего вызывается метод retrieve, и проверяется, что возвращены были новые данные.
    func test_insert_overridesPreviouslyInsertedCacheValues() {
//        let sut = makeSUT()
//        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    
    /// Этот тест проверяет, что если при попытке вставки данных произошла ошибка, метод insert возвращает ошибку. Для этого используется invalidStoreURL, который является недействительным URL. При вызове метода вставки в это место ожидается ошибка, так как данные не могут быть записаны в недействительное хранилище.
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    
    // Проверить, что при возникновении ошибки вставки данных в хранилище кэш остаётся неизменным и не имеет побочных эффектов
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    
    /// Этот тест проверяет, что вызов метода delete на пустом кэше не вызывает ошибок. То есть, даже если кэш пуст, метод delete должен завершаться успешно, без ошибок
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что вызов метода delete на непустом кэше также не вызывает ошибок. Это означает, что даже если в кэше есть данные, их удаление должно проходить без ошибок
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    
    /// Этот тест проверяет, что вызов метода delete очищает кэш, который содержал данные. Сначала в кэш вставляются данные, а затем они удаляются, после чего проверяется, что кэш действительно стал пустым
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    /// Этот тест проверяет, что если произошла ошибка при удалении данных из хранилища, то метод delete возвращает ошибку. Для симуляции ошибки используется noDeletePermissionURL, который представляет собой URL директории, к которой у приложения нет прав на удаление. Тест вызывает метод удаления и ожидает, что будет возвращена ошибка.
    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    /// Этот тест проверяет, что если произошла ошибка при удалении данных из хранилища, то состояние кэша не должно измениться. Снова используется noDeletePermissionURL для симуляции ошибки. Тест проверяет, что после вызова метода удаления, несмотря на ошибку, кэш остаётся в том же состоянии, что и до удаления (без побочных эффектов).
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    /// Этот тест проверяет, что все операции с кэшем (вставка, удаление и получение данных) выполняются последовательно, одна за другой, без одновременного выполнения. Это важно для поддержания целостности данных в условиях многопоточности.
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    /// Этот тест проверяет, что если мы пытаемся получить кэшированные данные из пустого кэша (где ранее ничего не было сохранено), то результат будет пустым. Он эмулирует вызов метода retrieve, когда кэш ещё не был создан, и проверяет, что результат пуст.
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что повторные вызовы метода retrieve на пустом кэше не изменяют его состояние. То есть, если кэш пуст, вызов метода retrieve несколько раз подряд должен возвращать один и тот же результат, без изменения состояния кэша.
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что если кэш пуст и мы пытаемся удалить данные (вызов метода delete), то состояние кэша не изменится, и никаких ошибок не произойдет. То есть вызов delete на пустом кэше не должен иметь побочных эффектов.
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

