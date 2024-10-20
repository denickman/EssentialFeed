//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 17.10.2024.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    /// Этот тест проверяет, что при попытке извлечь данные из пустого кэша, метод retrieve возвращает пустой результат (empty), указывая, что в хранилище нет данных.
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    /// Тест проверяет, что при многократном вызове метода retrieve на пустом кэше результат остаётся неизменным, то есть кэш не должен изменяться или генерировать какие-либо побочные эффекты.
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    
    /// Этот тест проверяет, что при наличии данных в кэше, метод retrieve возвращает корректные значения, соответствующие сохранённым ранее элементам и времени.
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    
    /// Тест проверяет, что при многократном вызове метода retrieve на непустом кэше возвращаемые значения остаются неизменными, подтверждая отсутствие побочных эффектов.
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    /// Этот тест проверяет, что при попытке вставить новые данные в пустой кэш операция проходит успешно, без ошибок.
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    /// Тест проверяет, что операция вставки новых данных в непустой кэш также завершится без ошибок, несмотря на то, что данные уже присутствуют.
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    
    /// Этот тест проверяет, что при повторной вставке данных в кэш они успешно перезаписывают предыдущие значения.
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    /// Тест проверяет, что удаление данных из пустого кэша не вызывает ошибок.
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    /// Тест проверяет, что многократное удаление данных из пустого кэша не приводит к побочным эффектам и не вызывает ошибок.
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    /// Тест проверяет, что операция удаления данных из непустого кэша проходит успешно и не вызывает ошибок.
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    /// Тест проверяет, что после удаления ранее вставленные данные действительно удаляются из кэша и кэш становится пустым.
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    /// Этот тест проверяет, что все побочные эффекты операций над хранилищем (вставка, удаление, извлечение) выполняются последовательно, без параллельного выполнения, что важно для целостности данных.
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        
        if let modelURL = storeBundle.url(forResource: "FeedStore", withExtension: "momd") {
            print("Модель найдена по адресу: \(modelURL)")
        } else {
            print("Модель не найдена")
        }
        
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}


