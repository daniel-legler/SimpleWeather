//
//  UIButton+Customizations.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 10/29/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit

extension UIButton {
    func customize() {
        self.layer.cornerRadius = 11.0
        self.transform = CGAffineTransform(rotationAngle: CGFloat(.pi / 4.0))
    }
}
