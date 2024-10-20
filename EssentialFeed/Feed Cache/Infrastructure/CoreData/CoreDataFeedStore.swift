//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 17.10.2024.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    /// NSPersistentContainer управляет Core Data стеком, включая модель данных и хранилища. Это основа работы с Core Data.
    private let container: NSPersistentContainer
    
    /// NSManagedObjectContext — это контекст, в котором выполняются все операции с объектами Core Data (чтение, запись и т.д.). В данном случае используется контекст, работающий в фоне.
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        
        /// Этот инициализатор принимает storeURL — URL, где будет храниться база данных, и bundle, где находится модель данных Core Data.
        /// Он использует метод load (из предыдущего расширения), чтобы загрузить контейнер Core Data с моделью FeedStore и настроить хранилище.
        /// После этого инициализируется новый фоновый контекст с помощью newBackgroundContext(). Этот контекст будет использоваться для выполнения всех операций в фоне, что помогает избежать блокировок основного потока.
        /// 
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    // you can use it without .some as well
                    completion(.success(.some(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp))))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
}
