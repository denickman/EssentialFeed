//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 24.10.2024.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
