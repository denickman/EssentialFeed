//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.10.2024.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    // MARK: - Properties
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    // MARK: - Init
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    // MARK: - Methods
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(
            feed.toLocal(),
            timestamp: self.currentDate(),
            completion: { [weak self] error in
                guard self != nil else { return }
                completion(error)
            })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )}
    }
}
