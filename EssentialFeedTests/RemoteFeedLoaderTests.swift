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
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        // Given
        let (sut, client) = makeSUT()
        let samples = [199]
        
        // When
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(with: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        // Given
        let (sut, client) = makeSUT()
        
        // When
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "invalid_json".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data(bytes: "{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyListJSON)
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut: sut, client: client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var captureResults = [RemoteFeedLoader.Result]()
        sut.load { captureResults.append($0) }
        
        action()
        
        XCTAssertEqual(captureResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        // MARK: - Properties
        
        var requestedURL: URL?
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        // MARK: - Methods
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            with statusCode: Int,
            data: Data = Data(),
            at index: Int = 0
        ) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
