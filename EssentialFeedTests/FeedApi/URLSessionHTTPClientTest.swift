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
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receiveURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receiveURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        
    }
}
