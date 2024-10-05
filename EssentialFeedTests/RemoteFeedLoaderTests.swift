//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 02.10.2024.
//

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        // Given
        let (sut, client) = makeSUT()
        
        // Then
        XCTAssertNil(client.requestedURL)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromUrl() {
        
        // Given
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        // When
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        // given
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT()
        
        // when
        sut.load { _ in }
        sut.load { _ in }
        
        // then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // Given
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        // When
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
//        client.completions[0](clientError)
        
        client.complete(with: clientError)
        
        // Then
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        // Given
        let (sut, client) = makeSUT()
        let samples = [199, 200, 300, 400, 500]
        
        // When
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            
            sut.load { capturedErrors.append($0) }
            client.complete(with: code, at: index)
            
            // Then
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut: sut, client: client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
//        var completions = [(Error) -> Void]()
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
//            completions.append(completion)
//            requestedURLs.append(url)
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
//            completions[index](error)
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, at index: Int = 0) {
            
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(response))
            
            
        }
    }
}
