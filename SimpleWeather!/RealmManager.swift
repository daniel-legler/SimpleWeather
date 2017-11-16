//
//  RealmManager.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 8/15/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import CoreData
import UIKit
import CoreLocation
import RealmSwift

final class RealmManager {
        
    var currentCity: String? {
        
        do {
            
            let realm = try Realm()
            
            return Array(realm.objects(Location.self).filter("isCurrentLocation == true")).first?.city ?? nil
            
        } catch {
            print(error.localizedDescription)
            return nil
        }

    }
    
    func save(_ location: Location, completion: @escaping (WeatherApiError) -> Void ) {
        print("Called Save Location")

        do {
            
            let realm = try Realm()
            
            let update: Bool = realm.object(ofType: Location.self, forPrimaryKey: location.city) != nil ? true : false
            
            try realm.write {
                realm.add(location, update: update)
            }
            
        } catch {
            completion(.realmError); print(error.localizedDescription)
        }
    }
    
    func save(_ locations: [Location], completion: @escaping (WeatherApiError) -> Void ) {
        print("Called Save Locations")
        do {
            
            let realm = try Realm()
                        
            try realm.write {
                realm.add(locations, update: true)
            }
            
        } catch {
            completion(.realmError); print(error.localizedDescription)
        }
    }
    
    func delete(_ city: String, _ completion: (WeatherApiError) -> Void) {
        
        do {
            
            let realm = try Realm()
            
            if let object = realm.object(ofType: Location.self, forPrimaryKey: city) {
                
                try realm.write {
                    realm.delete(object)
                }
            }
            
        } catch {
            completion(.realmError); print(error.localizedDescription)
        }

    }
    
    func locations() -> [Location]? {
        
        do {
            
            let realm = try Realm()
            
            let locations = Array(realm.objects(Location.self))
            
            return locations
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func updateCurrentLocation(city: String, completion: @escaping (Bool) -> Void ) {

        do {
            
            let realm = try Realm()
            
            let savedCurrentLocation = Array(realm.objects(Location.self).filter("isCurrentLocation == true")).first
            let savedLocationForCity = realm.object(ofType: Location.self, forPrimaryKey: city)
            
            // Case 0: User location hasn't been saved yet
            if savedCurrentLocation == nil {
                completion(false)
            }
            
            // Case 1: Haven't Changed Cities, User Did Add City as Custom Location
            // Case 2: Haven't Changed Cities, User Did NOT Add City as Custom Location
            else if savedCurrentLocation!.city == city {
                completion(savedCurrentLocation!.isCustomLocation)
            }
            
            // Case 3: Have Changed Cities, User Did Add City as Custom Location
            else if savedCurrentLocation!.isCustomLocation {
                try realm.write {
                    savedCurrentLocation!.isCurrentLocation = false
                    if let newCurrentLocation = savedLocationForCity {
                        newCurrentLocation.isCurrentLocation = true
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
            
            // Case 4: Have Changed Cities, User Did NOT Add City as Custom Location
            else {
                try realm.write {
                    realm.delete(savedCurrentLocation!)
                    if let newCurrentLocation = savedLocationForCity {
                        newCurrentLocation.isCurrentLocation = true
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
            
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
}
