//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 14.10.2024.
//

import Foundation

final class FeedCachePolicy {
    
    // MARK: - Properties
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCachedAgeInDays: Int { 7 }
    
    private init() {}

    // MARK: - Methods
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

