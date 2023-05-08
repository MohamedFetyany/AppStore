//
//  UIButton+TestHelpers.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 08/05/2023.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
