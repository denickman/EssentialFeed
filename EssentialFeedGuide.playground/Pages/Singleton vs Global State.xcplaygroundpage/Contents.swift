
import UIKit

/*
 
 The Singleton pattern as described in the Design Patterns book (GOF) by Gamma, Johnson, Vlissides, and Helm is a way to make sure that a class has only one instance and it provides a single point of access to it. The pattern specifies that the class itself should be responsible for keeping track of its sole instance. It can further ensure that no other instance can be created by intercepting requests for creating new objects and provide a way to access the sole instance.
 */


class ApiClient {
    static let instance = ApiClient()
    
    private init() {}
    
    func execute(_ : URLRequest, completion: (Data) -> Void) {}
    
    //    func login(comletion: @escaping (LoggedInUser) -> Void) {}
    //    func loadFeed(completion: @escaping ([FeedItem]) -> Void) {}
}

// Main module

struct LoggedInUser {}

extension ApiClient {
    func login(comletion: @escaping (LoggedInUser) -> Void) {}
}

struct FeedItem {}

extension ApiClient {
    func loadFeed(completion: ([FeedItem]) -> Void) {
        print(">> 2")
           // Логика загрузки элементов ленты
           let feedItems = [FeedItem]() // Здесь должна быть логика получения данных
           completion(feedItems) // Возвращаем загруженные элементы через замыкание
       }
}

// Feed module

class FeedViewModel {
    
    var loadFeed: ((([FeedItem]) -> Void) -> Void)?
    
    func load() {
        print(">> 0")
        loadFeed? { item in
            print(">> 4")
        }
    }
}


/// Example # 1

let feedViewModel = FeedViewModel()

feedViewModel.loadFeed = { completion in
    print(">> 1")
    ApiClient.instance.loadFeed { items in
        print(">> 3")
        completion(items) // Передаем загруженные элементы в замыкание
    }
}

print(">> start")
feedViewModel.load() // Это вызовет метод загрузки и выведет загруженные элементы




/*
 
 Использование static var вместо static let в Singleton может быть оправдано в определенных случаях, когда требуется гибкость, но это должно быть сделано с осторожностью. Вот несколько сценариев, в которых может понадобиться static var:

 1. Необходимость изменения состояния
 Если в рамках вашего приложения есть потребность изменять состояние синглтона на лету, static var может быть полезен. Например, если синглетон представляет собой конфигурационный объект, состояние которого может изменяться в зависимости от настроек пользователя или других условий приложения, static var может дать возможность обновлять эти настройки.

 2. Переинициализация
 Иногда может понадобиться возможность переинициализации синглтона с новыми параметрами. Например, в ситуациях, когда приложение работает с разными средами (например, тестовая и продакшен), использование static var может позволить разработчикам устанавливать разные экземпляры в зависимости от условий.

 3. Тестирование
 В некоторых случаях для тестирования может понадобиться замена синглтона на временный экземпляр, который не влияет на глобальное состояние. С помощью static var можно переназначить экземпляр на другой в тестах, чтобы изолировать тестируемый код от глобального состояния.

 4. Гибкость в реализации
 Если проектирование системы подразумевает наличие механизма, который должен позволять динамически заменять реализацию или поведение синглтона, static var может обеспечить такую гибкость. Это может быть полезно для реализации паттерна стратегий или других паттернов, требующих замены поведения во время выполнения.

 Заключение
 Хотя static var может предоставить преимущества в определенных ситуациях, его использование требует внимательного подхода. Важно учитывать последствия, которые могут возникнуть из-за изменяемости состояния синглтона, такие как сложность в отладке и поддержке кода. В большинстве случаев, если нет явной необходимости в изменении состояния синглтона, рекомендуется использовать static let для предотвращения возможных проблем с состоянием и предсказуемостью.
 
 */
