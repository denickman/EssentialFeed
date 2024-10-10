//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Denis Yaremenko on 10.10.2024.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
}

class LocalFeedLoader {
    
    init(store: FeedStore) {
        
    }
}


final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
}
