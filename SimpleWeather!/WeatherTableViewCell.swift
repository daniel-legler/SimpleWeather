//
//  WeatherTableViewCell.swift
//  WeatherAppV3
//
//  Created by Daniel Legler on 3/4/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var weatherType: UILabel!
    
    @IBOutlet weak var highTemp: UILabel!
    
    @IBOutlet weak var lowTemp: UILabel!
    
    func configureCell(forecast: ForecastWeather, theme: Theme) {
        lowTemp.text = "\(String(Int(forecast.low)))°"
        highTemp.text = "\(String(Int(forecast.high)))°"
        weatherType.text = forecast.type
        dayLabel.text = forecast.date.dayOfTheWeek()
        let iconName = theme == .day ? forecast.type : forecast.type.appending("-dark")
        weatherIcon.image = UIImage(named: iconName)
    }
   
}
