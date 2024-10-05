//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 04.10.2024.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        //        HTTPClient.shared.requestedURL = URL(string: "https://google.com")
        //        client.get(from: URL(string: "https://a-url.com")!)
        client.get(from: url) { result in
            
            switch result {
            case .success:
                completion(.invalidData)
                
            case .failure:
                completion(.connectivity)
            }
        }
    }
}


