import UIKit
import Network

//typealias FeedLoader = (([String]) -> Void) -> Void)

protocol FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void)
}

class FeedViewController: UIViewController {
    
    // Option # 1 - depend on interface
    var loader: FeedLoader!
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.loadFeed { items in
            
        }
    }
}

class RemoteFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // do something
    }
}

class LocalFeedLoader: FeedLoader {
    func loadFeed(completion: @escaping ([String]) -> Void) {
        // do something
    }
}

class RemoteWithLocalFallBackFeedLoader: FeedLoader {

    // Option # 1 - depend on interface
    var localLoader: LocalFeedLoader!
    var remoteLoader: RemoteFeedLoader!
    
    var isNetworkAvailable: Bool = false
    
    init(local: LocalFeedLoader, remote: RemoteFeedLoader) {
        self.localLoader = local
        self.remoteLoader = remote
    }
    
    func loadFeed(completion: @escaping ([String]) -> Void) {
        let load = isNetworkAvailable ? remoteLoader.loadFeed : localLoader.loadFeed
        load(completion)
    }
}


let vc1 = FeedViewController(loader: RemoteFeedLoader())
let vc2 = FeedViewController(loader: LocalFeedLoader())

let vc3 = FeedViewController()

vc3.loader = RemoteWithLocalFallBackFeedLoader(
    local: LocalFeedLoader(),
    remote: RemoteFeedLoader()
)
