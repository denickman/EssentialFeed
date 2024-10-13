//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.10.2024.
//

import Foundation

public protocol FeedStore {
    
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
    
}


