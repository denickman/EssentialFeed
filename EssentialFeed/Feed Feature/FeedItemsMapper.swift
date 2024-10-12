//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 06.10.2024.
//

import Foundation


struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var item: FeedItem {
        .init(id: id, description: description, location: location, imageURL: image)
    }
}

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
