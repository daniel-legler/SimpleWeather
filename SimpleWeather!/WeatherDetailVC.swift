//
//  WeatherDetailVC.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 3/2/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit

class WeatherDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var weatherTodayView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var location: Location?
    
    var theme: Theme {
        return location != nil ? Theme.at(location!) : Theme.day
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isMotionEnabled = true
        weatherTodayView.motionIdentifier = location?.city

        configureView()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .right
        swipeDown.numberOfTouchesRequired = 1
        weatherTodayView.isUserInteractionEnabled = true
        weatherTodayView.addGestureRecognizer(swipeDown)
        
    }
    
    func configureView() {
        dateLabel.text = Date().todayString()
        tempLabel.text = "\(Int(location?.current?.temp ?? 0.0))°"
        locationLabel.text = location?.city
        weatherTypeLabel.text = location?.current?.type
        weatherTodayView.backgroundColor = theme.secondary()
        let iconName = location?.current?.type.appending(theme == .night ? "-dark" : "") ?? "Unkown"
        weatherImage.image = UIImage(named: iconName)
    }
    
    @objc
    func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {

        if sender.state == .ended {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location?.forecasts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WeatherTableViewCell,
            let forecast = location?.forecasts[indexPath.row] else {
                return WeatherTableViewCell()
            }
        
        cell.configureCell(forecast: forecast)
    
        return cell
    
    }
}
