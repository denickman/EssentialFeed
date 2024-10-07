//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 07.10.2024.
//

import XCTest

class URLSessionHTTPClient {
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Init
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Methods
    
    func get(from url: URL) {
        session.dataTask(with: url) { data, response, error in
            
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
        sut.get(from: url)
        
        
        // THEN
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        
        // MARK: - Properties
        
        private var stubs = [URL: URLSessionDataTask]()
        
        // MARK: - Methods
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
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







/*
 //
 //  URLSessionHTTPClientTest.swift
 //  EssentialFeedTests
 //
 //  Created by Denis Yaremenko on 07.10.2024.
 //

 import XCTest

 class URLSessionHTTPClient {
     // MARK: - Properties
     
     private let session: URLSession
     
     // MARK: - Init
     
     init(session: URLSession) {
         self.session = session
     }
     
     // MARK: - Methods
     
     func get(from url: URL) {
         session.dataTask(with: url) { data, response, error in
             
         }
         .resume()
     }
 }


 final class URLSessionHTTPClientTest: XCTestCase {
     
     func test_getFromURL_createsDataTaskWithURL() {
         // GIVEN
         let url = URL(string: "http://any-url.com")!
         let session = URLSessionSpy()
         
         // WHEN
         let sut = URLSessionHTTPClient(session: session)
         sut.get(from: url)
         
         // THEN
         XCTAssertEqual(session.receiveURLs, [url])
     }
     
     func test_getFromURL_resumesDataTaskWithURL() {
         // GIVEN
         let url = URL(string: "http://any-url.com")!
         let session = URLSessionSpy()
         let task = URLSessionDataTaskSpy()
         session.stub(url: url, task: task)

         // WHEN
         let sut = URLSessionHTTPClient(session: session)
         sut.get(from: url)
         
         
         // THEN
         XCTAssertEqual(task.resumeCallCount, 1)
     }
     
     // MARK: - Helpers
     
     private class URLSessionSpy: URLSession {
         
         // MARK: - Properties
         
         var receiveURLs = [URL]()
         private var stubs = [URL: URLSessionDataTask]()
         
         // MARK: - Methods
         
         override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
             receiveURLs.append(url)
             return stubs[url] ?? FakeURLSessionDataTask()
         }
         
         func stub(url: URL, task: URLSessionDataTask) {
             stubs[url] = task
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
