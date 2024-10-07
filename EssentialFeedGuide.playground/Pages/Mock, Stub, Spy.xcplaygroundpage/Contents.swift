//: [Previous](@previous)

import Foundation

//Mock: Проверяет взаимодействия, используется для тестирования того, что методы были вызваны с ожидаемыми аргументами.
//Stub: Возвращает предопределенные данные, не проверяет взаимодействия.
//Spy: Записывает информацию о вызовах методов, позволяет проверить, какие методы были вызваны.



//Mock — это объект, который настроен для проверки взаимодействий. Он может следить за вызовами своих методов и возвращать предопределённые значения. Обычно используется для проверки, были ли вызваны определённые методы с ожидаемыми аргументами.

import XCTest

// Протокол для HTTP клиента
protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

// Mock для HTTP клиента
class HTTPClientMock: HTTPClient {
    var requestUrl: URL?
    var result: Result<Data, Error>?

    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        requestUrl = url
        if let result = result {
            completion(result)
        }
    }
}

// Тест
class MyTests: XCTestCase {
    func test_HTTPClientMock() {
        let mock = HTTPClientMock()
        let url = URL(string: "http://test.com")!
        mock.result = .success(Data())
        
        mock.get(from: url) { _ in }

        XCTAssertEqual(mock.requestUrl, url) // Проверяем, что был вызван с правильным URL
    }
}


//Stub — это объект, который возвращает предопределенные данные при вызове своих методов. Он не проверяет, как его методы были вызваны; его основная цель — обеспечить контролируемое окружение.

import XCTest

// Stub для HTTP клиента
class HTTPClientStub: HTTPClient {
    var data: Data?
    var error: Error?

    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        if let data = data {
            completion(.success(data))
        } else if let error = error {
            completion(.failure(error))
        }
    }
}

// Тест
class MyTests: XCTestCase {
    func test_HTTPClientStub() {
        let stub = HTTPClientStub()
        let expectedData = "Hello, world!".data(using: .utf8)
        stub.data = expectedData
        
        stub.get(from: URL(string: "http://test.com")!) { result in
            switch result {
            case let .success(data):
                XCTAssertEqual(data, expectedData) // Проверяем, что вернулось ожидаемое значение
            default:
                XCTFail("Expected success, got \(result) instead.")
            }
        }
    }
}


//Spy — это объект, который записывает информацию о вызовах своих методов. Он позволяет проверять, какие методы были вызваны и с какими аргументами, но при этом может выполнять реальную логику.


import XCTest

// Spy для HTTP клиента
class HTTPClientSpy: HTTPClient {
    var requests = [(url: URL, completion: (Result<Data, Error>) -> Void)]()

    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        requests.append((url, completion))
    }
}

// Тест
class MyTests: XCTestCase {
    func test_HTTPClientSpy() {
        let spy = HTTPClientSpy()
        let url = URL(string: "http://test.com")!

        spy.get(from: url) { _ in }

        XCTAssertEqual(spy.requests.count, 1) // Проверяем, что метод был вызван один раз
        XCTAssertEqual(spy.requests.first?.url, url) // Проверяем правильный URL
    }
}


