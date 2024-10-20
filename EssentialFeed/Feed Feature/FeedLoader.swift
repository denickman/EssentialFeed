//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

//public enum LoadFeedResult {
//	case success([FeedImage])
//	case failure(Error)
//}

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
