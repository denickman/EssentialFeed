//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Denis Yaremenko on 24.10.2024.
//

import UIKit


extension UIButton {
   func simulateTap() {
       simulate(event: .touchUpInside)
   }
}
