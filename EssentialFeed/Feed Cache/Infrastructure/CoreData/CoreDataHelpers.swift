//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 17.10.2024.
//

import CoreData

extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound //  возникает, если модель данных с указанным именем не найдена в указанном бандле
        case failedToLoadPersistentStores(Swift.Error) // возникает, если не удалось загрузить persistent store, в том числе если возникает какая-либо ошибка при подключении хранилищ данных.
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        /// Создается объект NSPersistentStoreDescription, описывающий параметры persistent store. В данном случае указывается URL, куда будет сохраняться база данных (SQLite файл, например).
        let description = NSPersistentStoreDescription(url: url)
        
        /// Инициализируется экземпляр NSPersistentContainer, который управляет моделью данных (NSManagedObjectModel). Он используется для управления Core Data стеком, который включает хранилище (persistent store), объекты управления (managed object contexts) и т.д.
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        /// Описания хранилищ (persistentStoreDescriptions) устанавливаются для контейнера. Это определяет, как и где будут храниться данные Core Data (например, в файле по указанному URL).
        container.persistentStoreDescriptions = [description]
        
        /// Метод loadPersistentStores загружает хранилище данных, используя ранее созданное описание (NSPersistentStoreDescription).
        /// В замыкании проверяется вторая переменная $1, которая представляет собой возможную ошибку, произошедшую при загрузке хранилищ. Если она есть, то она сохраняется в переменной loadError.
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        
        /// Здесь происходит проверка ошибки, которая была сохранена в loadError. Если ошибка произошла, она мапится на выбрасывание новой ошибки LoadingError.failedToLoadPersistentStores, которая оборачивает исходную ошибку.
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
