//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 09.10.2024.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInerceptingRequest()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInerceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
//        exp.expectedFulfillmentCount = 2

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        let exp2 = expectation(description: "Wait for request completion")
        
        makeSUT().get(from: url) { completion in exp2.fulfill() }
        
        wait(for: [exp, exp2], timeout: 1.0)
    }
    
    func test_getFromURL_performsGETRequestWithURL_UsingArrayOfRequests() {
        let url = anyURL()
        var receivedRequests = [URLRequest]()
        
        URLProtocolStub.observeRequests { request in
            receivedRequests.append(request)
        }
        
        let exp = expectation(description: "Wait for request completion")
        
        makeSUT().get(from: url) { completion in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedRequests.count, 1)
        XCTAssertEqual(receivedRequests.first?.url, url)
        XCTAssertEqual(receivedRequests.first?.httpMethod, "GET")
    }
    
    func test_getFromURL_failsOnRequestError() {
        // GIVEN
        let requestError = anyError()
        
        // WHEN
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        // THEN
        //        XCTAssertEqual(receivedError as NSError?, requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: nil))
        //        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        // GIVEN
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        // WHEN
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        // THEN
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        // GIVEN
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        // WHEN
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        // THEN
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case .failure(let error):
            return error
            
        default:
            XCTFail("Expected failure, got \(result) instead.", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
            
        default:
            XCTFail("Expected success, got \(result) instead.", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        Data(bytes: "anydata".utf8)
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    // MARK: - URLProtocolStub
    
    private class URLProtocolStub: URLProtocol {
        
        // MARK: - Properties
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var requestObserver: ((URLRequest) -> Void)?
        private static var stub: Stub?
        
        // MARK: - Override Methods
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        // MARK: - Methods
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInerceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInerceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
    }
}






/*
 
 1. canInit(with:)
 swift
 Copy code
 override class func canInit(with request: URLRequest) -> Bool
 Описание:
 
 Этот метод определяет, должен ли данный URLProtocol обрабатывать запрос.
 Он вызывается всякий раз, когда создаётся сетевой запрос с помощью URLSession.
 Возвращает true, если запрос должен быть обработан этой заглушкой, и false в противном случае.
 В твоём коде заглушка проверяет наличие URL в URLProtocolStub.stubs, чтобы определить, обрабатывать ли запрос.
 Когда вызывается:
 
 Когда URLSession создаёт dataTask, она вызывает этот метод, чтобы проверить, нужно ли использовать URLProtocolStub для обработки данного запроса.
 
 
 override class func canInit(with request: URLRequest) -> Bool {
 guard let url = request.url else { return false }
 return URLProtocolStub.stubs[url] != nil
 }
 
 
 
 2. canonicalRequest(for:)
 swift
 Copy code
 override class func canonicalRequest(for request: URLRequest) -> URLRequest
 Описание:
 
 Этот метод вызывается для предоставления канонической версии запроса.
 Обычно он возвращает тот же запрос, который был передан в качестве аргумента, если нет необходимости его модифицировать.
 Когда вызывается:
 
 После того, как система определяет, что запрос может быть обработан с помощью этого URLProtocol (на основе ответа canInit(with:)), она вызывает canonicalRequest(for:), чтобы получить окончательную версию запроса.
 
 override class func canonicalRequest(for request: URLRequest) -> URLRequest {
 return request
 }
 
 
 override func startLoading()
 
 
 
 3. startLoading()
 swift
 Copy code
 override func startLoading()
 Описание:
 
 Этот метод вызывается для начала загрузки данных.
 Внутри него ты имитируешь ответ сервера с использованием заранее подготовленных данных, ответа и/или ошибки, которые были установлены в заглушке с помощью метода stub(url:data:response:error:).
 
 Логика:
 
 Метод находит соответствующий Stub для запрашиваемого URL и:
 Если у заглушки есть данные (data), они передаются клиенту через метод client?.urlProtocol(self, didLoad:).
 Если у заглушки есть ответ (response), он передаётся через client?.urlProtocol(self, didReceive:cacheStoragePolicy:).
 Если есть ошибка (error), она передаётся через client?.urlProtocol(self, didFailWithError:).
 В конце обязательно вызывается client?.urlProtocolDidFinishLoading(self), чтобы уведомить о завершении загрузки.
 
 
 
 Логика:
 
 Метод находит соответствующий Stub для запрашиваемого URL и:
 Если у заглушки есть данные (data), они передаются клиенту через метод client?.urlProtocol(self, didLoad:).
 Если у заглушки есть ответ (response), он передаётся через client?.urlProtocol(self, didReceive:cacheStoragePolicy:).
 Если есть ошибка (error), она передаётся через client?.urlProtocol(self, didFailWithError:).
 В конце обязательно вызывается client?.urlProtocolDidFinishLoading(self), чтобы уведомить о завершении загрузки.
 
 
 override func startLoading() {
 guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
 return
 }
 
 if let data = stub.data {
 client?.urlProtocol(self, didLoad: data)
 }
 
 if let response = stub.response {
 client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
 }
 
 if let error = stub.error {
 client?.urlProtocol(self, didFailWithError: error)
 }
 
 client?.urlProtocolDidFinishLoading(self)
 }
 
 
 */
