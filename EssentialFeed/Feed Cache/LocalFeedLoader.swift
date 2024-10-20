//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 12.10.2024.
//

import Foundation

public final class LocalFeedLoader {
    
    // MARK: - Properties
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    // MARK: - Init
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    //  Эта функция отвечает за сохранение нового списка изображений (feed) в кеш.
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        // Сначала удаляет старый кеш, вызывая метод deleteCachedFeed у FeedStore.
        // удаляет предыдущие кешированные данные, прежде чем сохранить новые.
        
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                // Если при удалении кеша произошла ошибка, она передается через замыкание completion.
                completion(cacheDeletionError)
            } else {
                // Если ошибок нет, вызывается приватный метод cache для сохранения нового списка изображений в хранилище.
                self.cache(feed, with: completion)
            }
        }
    }
    
    // функция, которая непосредственно выполняет вставку новых данных в кеш.
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

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                // Если кеш найден и его данные валидны (проверяется через политику FeedCachePolicy.validate), возвращает данные через completion(.success(...)).
            case let .success(.found(feed, timestamp)) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
                
                // Если произошла ошибка при извлечении кеша, передает её через completion(.failure(...)).
            case let .failure(error):
                completion(.failure(error))
                
                // Если кеш пуст или данные устарели, возвращает пустой массив (completion(.success([]))).
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    // Эта функция отвечает за проверку действительности кеша и его удаление, если данные устарели или произошла ошибка.
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                // Если произошла ошибка при извлечении, кеш удаляется.
                self.store.deleteCachedFeed { _ in }
                
                // Если кеш найден, но его время истекло (проверяется с помощью FeedCachePolicy.validate), кеш также удаляется.
            case let .success(.found(_, timestamp)) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
                // сли кеш пуст или действителен, ничего не происходит.
            case .success: break
            }
        }
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

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )}
    }
}
