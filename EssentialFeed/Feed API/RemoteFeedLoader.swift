//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 04.10.2024.
//

import Foundation

public class RemoteFeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    // MARK: - Properties
    
    private let url: URL
    private let client: HTTPClient
    
    // MARK: - Init
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    // MARK: - Methods
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }

}
