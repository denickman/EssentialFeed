//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.10.2024.
//

import Foundation

enum FeedItemsMapper {
    
    private static var OK_200: Int { return 200 }
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
