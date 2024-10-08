//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 07.10.2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Init
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Methods
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        let url = URL(string: "http://wrong-url.com")!
        
        
        session.dataTask(with: url) { data, response, error in
            
            if let error {
                completion(.failure(error))
            }
        }
        .resume()
    }
}


final class URLSessionHTTPClientTest: XCTestCase {
    
    
    func test_getFromURL_failsOnRequestError() {
        
        // GIVEN
        
        URLProtocolStub.startInerceptingRequest()
        
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        // WHEN
        
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                // not comparable due to urlsession adding extra data during processing the error
                //                XCTAssertEqual(receivedError, error)
                
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
                
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInerceptingRequest()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        // MARK: - Properties
        
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        
        // MARK: - Override Methods
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
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
        }
    }
}










/* Protocol approach
 
 import XCTest
 import EssentialFeed
 
 protocol HTTPSession {
 func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
 }
 
 protocol HTTPSessionTask {
 func resume()
 }
 
 
 class URLSessionHTTPClient {
 // MARK: - Properties
 
 private let session: HTTPSession
 
 // MARK: - Init
 
 init(session: HTTPSession) {
 self.session = session
 }
 
 // MARK: - Methods
 
 func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
 session.dataTask(with: url) { data, response, error in
 print("completion here>>>")
 
 if let error {
 completion(.failure(error))
 }
 }
 .resume()
 }
 }
 
 
 
 final class URLSessionHTTPClientTest: XCTestCase {
 
 func test_getFromURL_resumesDataTaskWithURL() {
 
 // GIVEN
 
 let url = URL(string: "http://any-url.com")!
 let session = HTTPSessionSpy()
 let task = URLSessionDataTaskSpy()
 session.stub(url: url, task: task)
 
 // WHEN
 
 let sut = URLSessionHTTPClient(session: session)
 sut.get(from: url) { _ in }
 
 // THEN
 
 XCTAssertEqual(task.resumeCallCount, 1)
 }
 
 func test_getFromURL_failsOnRequestError() {
 
 // GIVEN
 
 let url = URL(string: "http://any-url.com")!
 let error = NSError(domain: "any error", code: 1)
 let session = HTTPSessionSpy()
 
 session.stub(url: url, error: error)
 
 // WHEN
 
 let sut = URLSessionHTTPClient(session: session)
 let exp = expectation(description: "Wait for completion")
 
 sut.get(from: url) { result in
 switch result {
 case let .failure(receivedError as NSError):
 XCTAssertEqual(receivedError, error)
 
 default:
 XCTFail("Expected failure with error \(error), got \(result) instead.")
 }
 
 exp.fulfill()
 }
 
 wait(for: [exp], timeout: 1.0)
 }
 
 // MARK: - Helpers
 
 private class HTTPSessionSpy: HTTPSession {
 
 // MARK: - Properties
 
 private var stubs = [URL: Stub]()
 
 
 private struct Stub {
 let task: HTTPSessionTask
 let error: Error?
 }
 
 // MARK: - Methods
 
 func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
 guard let stub = stubs[url] else {
 fatalError("Could not find stub for a given url")
 }
 completionHandler(nil, nil, stub.error)
 return stub.task
 }
 
 func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
 stubs[url] = Stub(task: task, error: error)
 }
 }
 
 private class FakeURLSessionDataTask: HTTPSessionTask {
 func resume() {
 
 }
 }
 
 private class URLSessionDataTaskSpy: HTTPSessionTask {
 
 var resumeCallCount = 0
 
 func resume() {
 resumeCallCount += 1
 }
 }
 }
 
 */



/* Subclassing approach
 
 import XCTest
 import EssentialFeed
 
 class URLSessionHTTPClient {
 // MARK: - Properties
 
 private let session: URLSession
 
 // MARK: - Init
 
 init(session: URLSession) {
 self.session = session
 }
 
 // MARK: - Methods
 
 func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
 session.dataTask(with: url) { data, response, error in
 print("completion here>>>")
 
 if let error {
 completion(.failure(error))
 }
 }
 .resume()
 }
 }
 
 
 final class URLSessionHTTPClientTest: XCTestCase {
 
 func test_getFromURL_resumesDataTaskWithURL() {
 
 // GIVEN
 
 let url = URL(string: "http://any-url.com")!
 let session = URLSessionSpy()
 let task = URLSessionDataTaskSpy()
 session.stub(url: url, task: task)
 
 // WHEN
 
 let sut = URLSessionHTTPClient(session: session)
 sut.get(from: url) { _ in }
 
 // THEN
 
 XCTAssertEqual(task.resumeCallCount, 1)
 }
 
 func test_getFromURL_failsOnRequestError() {
 
 // GIVEN
 
 let url = URL(string: "http://any-url.com")!
 let error = NSError(domain: "any error", code: 1)
 let session = URLSessionSpy()
 
 session.stub(url: url, error: error)
 
 // WHEN
 
 let sut = URLSessionHTTPClient(session: session)
 let exp = expectation(description: "Wait for completion")
 
 sut.get(from: url) { result in
 switch result {
 case let .failure(receivedError as NSError):
 XCTAssertEqual(receivedError, error)
 
 default:
 XCTFail("Expected failure with error \(error), got \(result) instead.")
 }
 
 exp.fulfill()
 }
 
 wait(for: [exp], timeout: 1.0)
 }
 
 // MARK: - Helpers
 
 private class URLSessionSpy: URLSession {
 
 // MARK: - Properties
 
 private var stubs = [URL: Stub]()
 
 
 private struct Stub {
 let task: URLSessionDataTask
 let error: Error?
 }
 
 // MARK: - Methods
 
 override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
 guard let stub = stubs[url] else {
 fatalError("Could not find stub for a given url")
 }
 completionHandler(nil, nil, stub.error)
 return stub.task
 }
 
 func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
 stubs[url] = Stub(task: task, error: error)
 }
 }
 
 private class FakeURLSessionDataTask: URLSessionDataTask {
 override func resume() {
 
 }
 }
 
 private class URLSessionDataTaskSpy: URLSessionDataTask {
 
 var resumeCallCount = 0
 
 override func resume() {
 resumeCallCount += 1
 }
 }
 }
 
 
 
 
 */







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
