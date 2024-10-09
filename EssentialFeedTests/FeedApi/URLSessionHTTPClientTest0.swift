//
//  URLSessionHTTPClientTest0.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 09.10.2024.
//

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



final class URLSessionHTTPClientTest0: XCTestCase {
    
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
 
 
 final class URLSessionHTTPClientTest0: XCTestCase {
 
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
