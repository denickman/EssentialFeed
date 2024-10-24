//
//  UIControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 24.10.2024.
//

import UIKit

 extension UIControl {
     func simulate(event: UIControl.Event) {
         allTargets.forEach { target in
             actions(forTarget: target, forControlEvent: event)?.forEach {
                 (target as NSObject).perform(Selector($0))
             }
         }
     }
 }
