//
//  Double+Celcius.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 10/29/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import Foundation

extension Double {
    func kelvinToFarenheit() -> Double {
        return (self * (9/5) - 459.67).rounded()
    }
}
