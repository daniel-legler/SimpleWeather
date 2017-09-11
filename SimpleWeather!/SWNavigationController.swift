//
//  SWNavigationController.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 9/5/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit
import Material

class SWNavigationController: UINavigationController {
        open override func viewDidLoad() {
            super.viewDidLoad()
            isMotionEnabled = true
            motionNavigationTransitionType = .autoReverse(presenting: .zoomSlide(direction: .left))
        }
}
