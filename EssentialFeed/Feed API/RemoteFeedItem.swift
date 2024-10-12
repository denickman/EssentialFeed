//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.10.2024.
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

