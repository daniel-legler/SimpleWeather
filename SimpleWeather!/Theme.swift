//
//  Theme.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 10/25/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

enum Theme {
    case day
    case night
}

extension Theme {
    
    static func now() -> Theme {
        let hour = Calendar.current.component(.hour, from: Date())
        return themeAtHour(hour)
    }
    
    static func themeAtHour(_ hour: Int) -> Theme {
        switch hour {
        case 0...6, 18...24:
            return Theme.night
        case 7...17:
            return Theme.day
        default:
            return Theme.day
        }
    }
    
    static func at(_ location: Location) -> Theme {
        
        let coord = location.getCoordinate()
        
        guard let timezone = TimezoneMapper.latLngToTimezone(coord) else {
            return Theme.day
        }
        
        let dateComponents = Calendar.current.dateComponents(in: timezone, from: Date())
        
        guard let hour = dateComponents.hour else {
            return Theme.day
        }
        
        return themeAtHour(hour)

    }
    
    func primary() -> UIColor {
        switch self {
        case .day:
            return UIColor(named: "SWDayPrimary")!
        case .night:
            return UIColor(named: "SWNightPrimary")!
        }
    }
    
    func secondary() -> UIColor {
        switch self {
        case .day:
            return UIColor(named: "SWDaySecondary")!
        case .night:
            return UIColor(named: "SWNightSecondary")!
        }
    }

    static func primaryNow() -> UIColor {
        return now().primary()
    }
    
    static func secondaryNow() -> UIColor {
        return now().secondary()
    }
    
    static func setNavigationAttributes() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 18)!,
                                                             NSForegroundColorAttributeName: Theme.primaryNow()],
                                                            for: .normal )
        let navAppearance = UINavigationBar.appearance()
        navAppearance.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 20)!,
                                             NSForegroundColorAttributeName: Theme.primaryNow()]
        navAppearance.tintColor = Theme.primaryNow()
        navAppearance.backgroundColor = Theme.primaryNow()
    }
    
}
