//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

//extension FeedItem: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case description
//        case location
//        case imageURL = "image"
//    }
//}


/*
 
 case imageURL = "image"
 
 Если вы будете использовать это в другом модуле или в других частях вашего приложения, то возможны следующие проблемы:

 Изменение структуры API: Если API изменится и ключ image будет переименован, это может привести к ошибкам декодирования. Если код завязан на конкретные строки, вам нужно будет обновить все места, где используются эти ключи.
 
 Разделение модулей: Если ваша структура FeedItem используется в других модулях или библиотеках, изменения в формате JSON могут вызвать проблемы в этих модулях, если они зависят от того, как именно производится декодирование.
 
 Увеличение сложности: При использовании множественных модулей код может стать сложнее для понимания и поддержки, если структура и ключи не будут хорошо документированы. Это может привести к путанице при работе с данными.
 
 */
