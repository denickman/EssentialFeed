//: [Previous](@previous)

import Foundation

/// URLProtocol — это базовый класс, который предоставляет механизм для перехвата и обработки URL-запросов, выполненных с помощью URLSession. Он позволяет вам изменять, подменять или обрабатывать запросы и ответы, не изменяя основной сетевой стек. Это особенно полезно для тестирования, так как позволяет имитировать ответы от сервера и перехватывать запросы без необходимости в реальной сети.
///
/// Основные этапы работы с URLProtocol
/// Создание подкласса URLProtocol: Вам нужно создать свой класс, наследующий от URLProtocol, в котором вы будете реализовывать логику обработки запросов.
/// Регистрация вашего URLProtocol: После создания класса вам нужно зарегистрировать его с помощью URLProtocol.registerClass(_:), чтобы URLSession использовал его для всех запросов.
/// Обработка запросов: В вашем подклассе вы переопределите методы для обработки запросов, такие как canInit(with:), startLoading() и stopLoading().
/// Создание тестов: Используйте зарегистрированный класс в тестах для перехвата сетевых запросов и имитации ответов.
///

// 1. Создаем класс, наследующий от URLProtocol
class MockURLProtocol: URLProtocol {
    // Словарь для хранения мока ответов
    static var stubbedResponses: [URL: (Data?, URLResponse?, Error?)] = [:]

    // Определяем, можем ли мы обработать данный запрос
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Мы обрабатываем все запросы
    }

    // Устанавливаем уникальный идентификатор для запроса
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Запускаем загрузку запроса
    override func startLoading() {
        // Получаем ответ из словаря
        guard let url = request.url,
              let stubbedResponse = MockURLProtocol.stubbedResponses[url] else {
            return
        }

        // Извлекаем данные, ответ и ошибку
        let (data, response, error) = stubbedResponse

        // Отправляем ответ через `client`
        if let error = error {
            client?.urlProtocol(self, didFailWith: error, isRecoverable: false)
        } else {
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
        }

        // Завершаем загрузку
        client?.urlProtocolDidFinishLoading(self)
    }

    // Останавливаем загрузку
    override func stopLoading() {}
}



import XCTest

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    func test_getFromURL_returnsSuccessResponse() {
        // GIVEN
        let url = URL(string: "http://any-url.com")!
        let expectedData = "Hello, World!".data(using: .utf8)
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Подменяем ответ
        MockURLProtocol.stubbedResponses[url] = (expectedData, expectedResponse, nil)

        let expectation = self.expectation(description: "Wait for completion")
        let sut = URLSession.shared
        
        // WHEN
        sut.dataTask(with: url) { data, response, error in
            // THEN
            XCTAssertNil(error)
            XCTAssertEqual(data, expectedData)
            XCTAssertEqual(response as? HTTPURLResponse, expectedResponse)
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_getFromURL_returnsErrorResponse() {
        // GIVEN
        let url = URL(string: "http://any-url.com")!
        let expectedError = NSError(domain: "any error", code: 0)

        // Подменяем ответ с ошибкой
        MockURLProtocol.stubbedResponses[url] = (nil, nil, expectedError)

        let expectation = self.expectation(description: "Wait for completion")
        let sut = URLSession.shared
        
        // WHEN
        sut.dataTask(with: url) { data, response, error in
            // THEN
            XCTAssertNotNil(error)
            XCTAssertEqual(error as NSError?, expectedError)
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 1.0)
    }
}
