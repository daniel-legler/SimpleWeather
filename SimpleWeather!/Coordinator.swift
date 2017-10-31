//
//  LibraryAPI.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 8/9/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import Foundation
import CoreLocation

// This class is the interface between the UI and Realm/Networking classes
// Implementation of the facade design pattern.
final class Coordinator {
    
    // Download new weather for a city
    // Delete weather for a city
    // Update all weather
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(addLocalWeatherIfAvailable), name: .SWLocationAvailable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveWeather), name: .SWNewWeatherDownloaded, object: nil)
    }
    
    static let shared = Coordinator()
    
    func setup() {
       // Used to initialize shared instance
    }
    
    private let WAM = WeatherApiManager()
    private let RLM = RealmManager()
    private let CLM = CoreLocationManager()
    
    private var currentCity: String? {
        return RLM.currentCity
    }
    
    func locations() -> [Location]? {
        return RLM.locations()
    }
    
    func updateAllWeather(_ completion: @escaping (WeatherApiError?) -> Void ) {
        
        if connectedToNetwork() {
            
            var newLocations = [Location]()
            
            let group = DispatchGroup()
            
            guard let locations = RLM.locations() else { completion(.realmError); return }
            
            for loc in locations {
                                
                if loc.isCurrentLocation { continue }
                
                group.enter()

                downloadWeather(city: loc.city, coordinate: loc.getCoordinate(), flags: Flags(isCurrentLocation: false, isCustomLocation: true) ) { (location, error) in
                    
                    guard error == nil else { completion(error!); return }
                    
                    guard let newLocation = location else { completion(.realmError); return }
                    
                    newLocations.append(newLocation)
                    
                    group.leave()
                }
            
            }
            
            group.enter()
            downloadLocalWeather(completion: { (location, error) in
                
                guard let location = location, error == nil else {
                    group.leave()
                    return
                }
                
                newLocations.append(location)
                
                group.leave()
            })

            group.notify(queue: .global(), execute: {
                self.RLM.save(newLocations, completion: { (error) in
                    completion(error)
                })
            })
            
        } else {
            NotificationCenter.default.post(name: .SWNoNetworkConnection, object: self, userInfo: nil)
            completion(nil)
        }
    }
    
    func downloadWeather(city: String, coordinate: CLLocationCoordinate2D, flags: Flags, completion: @escaping (Location?, WeatherApiError?) -> Void) {
        
        WAM.downloadWeather(city: city, lat: coordinate.latitude, lon: coordinate.longitude, flags: flags) { (location, error) in
            
            guard error == nil else { completion(nil, error!); return }
            
            guard let location = location else { completion(nil, .realmError); return }

            completion(location, nil)
            
        }
        
    }
    
    // Delete Weather
    
    func deleteWeatherAt(city: String, completion: @escaping (WeatherApiError) -> Void) {
                
        RLM.delete(city) { error in
            completion(error)
        }
    }
    
    // Download Local Weather
    func downloadLocalWeather(completion: @escaping (Location?, WeatherApiError?) -> Void) {
        
        guard CLM.authStatus else {
            print("Location Auth Status Denied")
            return
        }
        
        CLM.findCity(completion: { (city) in
            
            guard let city = city, let coordinate = self.CLM.coordinate else {
                completion(nil, WeatherApiError.downloadError)
                return
            }
                        
            self.RLM.updateCurrentLocation(city: city) { wasCustomLocation in
                
                self.downloadWeather(city: city, coordinate: coordinate, flags: Flags(isCurrentLocation: true, isCustomLocation: wasCustomLocation), completion: { (location, error) in
                    
                    guard error == nil, let location = location else {
                        completion(nil, error!)
                        return
                    }
                    
                    completion(location, nil)
                   
                })
            }
        })
    }
    
    // Check if weather for current location is available
    
    @objc fileprivate func addLocalWeatherIfAvailable() {

        downloadLocalWeather { (location, error) in
            guard error == nil, let location = location else {
                print("Location was nil")
                return
            }
            
            self.RLM.save(location, completion: { _ in
                
            })
        }
        
    }
    
    @objc fileprivate func saveWeather(_ notification: Notification) {
        
        guard let location = notification.object as? Location else {
            print("Notification Came in, but without Location attached")
            return
        }
        
        RLM.save(location) { (error) in
            print(error.rawValue)
        }
    }

}
