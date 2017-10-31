//
//  OpenWeatherManager.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 8/8/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import Foundation
import RealmSwift

enum WeatherType: String {
    case clear = "Clear"
    case cloudy = "Cloudy"
    case rain = "Rain"
    case partiallyCloudy = "Partially Cloudy"
    case snow = "Snow"
    case thunderstorm = "Thunderstorm"
    case unknown = "Unknown"
}

enum WeatherApiError: String {
    case invalidCoordinates = "Invalid City"
    case downloadError = "Error Downloading"
    case jsonError = "Unexpected Server Response"
    case realmError = "Error Saving Weather"
}

typealias Flags = (isCurrentLocation: Bool, isCustomLocation: Bool)

class WeatherApiManager {
    
    private func forecastUrl(_ lat: Double, _ lon: Double) -> URL? {
        return URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&cnt=10&appid=0356f0d8e9865300021b8b2ba08ee811") ?? nil
    }
    
    private func currentWeatherUrl(_ lat: Double, _ lon: Double) -> URL? {
        return URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=0356f0d8e9865300021b8b2ba08ee811") ?? nil
    }
    
    private func weatherTypeForID(weatherID: Int) -> WeatherType? {
        
        switch weatherID {
            
        case 200...232: return .thunderstorm
        case 300...321, 500...531: return .rain
        case 600...622: return .snow
        case 700...781: return .cloudy
        case 800: return .clear
        case 800...804: return .cloudy
        case 900...962: return .unknown
        default: return nil
        
        }
    }
    
    func downloadWeather(city: String, lat: Double, lon: Double, flags: Flags, completion: @escaping(Location?, WeatherApiError?) -> Void) {
        
        guard let currentURL = currentWeatherUrl(lat, lon),
              let forecastURL = forecastUrl(lat, lon) else {
                
            completion(nil, .invalidCoordinates)
            return
        }
        
        var currentWeather = CurrentWeather()
        var forecasts = [ForecastWeather]()
        
        let group = DispatchGroup()
        group.enter() // API Call: Current Weather
        group.enter() // API Call: Forecast Weather
        
        weatherApiCall(url: currentURL) {
            guard $0 == nil, let json = $1 else { completion(nil, $0!); return }
            
            guard let current = self.currentWeatherFromJSON(json, completion: { completion(nil, $0); return }) else { completion(nil, .jsonError); return }
                
            currentWeather = current
            
            group.leave()
        }
        
        weatherApiCall(url: forecastURL) {
            guard $0 == nil, let json = $1 else { completion(nil, $0!); return }

            guard let allForecasts = self.forecastsFromJSON(json, completion: { completion(nil, $0); return }) else { completion(nil, .jsonError); return }
            
            forecasts = allForecasts
            
            group.leave()
        }

        // When finished downloading, return the Location via the completion handler
        group.notify(queue: DispatchQueue.global()) {
            
            let location = Location()
            location.city = city
            location.lat = lat
            location.lon = lon
            location.isCurrentLocation = flags.isCurrentLocation
            location.isCustomLocation = flags.isCustomLocation
            location.current = currentWeather
            location.forecasts.append(objectsIn: forecasts)

            completion(location, nil)
        }
    }
    
    private func weatherApiCall(url: URL, completion: @escaping (WeatherApiError?, [String:Any]?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                
                guard error == nil else { completion(.downloadError, nil); return }
                
                var parsedData = [String: Any]()
                do {
                    
                    try parsedData = JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:Any] ?? [:]
                    
                } catch {
                    completion(.jsonError, nil)
                    return
                }
                
                completion(nil, parsedData)
                
            }.resume()
        }
    }
    
    private func currentWeatherFromJSON(_ json: [String:Any], completion: @escaping (WeatherApiError) -> Void) -> CurrentWeather? {

        let currentWeather = CurrentWeather()

        // JSON Parsing to get current weather type
        guard let weather = json["weather"] as? [[String:Any]],
              let id = weather[0]["id"] as? Int,
              let directType = weather[0]["main"] as? String,
              let temperatureInfo = json["main"] as? [String:Any],
              let currentTemp = temperatureInfo["temp"] as? Double else { completion(.jsonError); return nil }
        
        currentWeather.type = self.weatherTypeForID(weatherID: id)?.rawValue ?? directType.capitalized
        currentWeather.temp = currentTemp.kelvinToFarenheit()
        
        return currentWeather
    }
    
    private func forecastsFromJSON(_ json: [String:Any], completion: @escaping (WeatherApiError) -> Void) -> [ForecastWeather]? {
        
        var forecasts = [ForecastWeather]()
        
        guard let allForecasts = json["list"] as? [[String:Any]] else { completion(.jsonError); return nil}
        
        for item in allForecasts {
            
            // JSON Parsing to get forecast high and low
            guard let temperatureInfo   = item["temp"] as? [String:Any],
                  let date              = item["dt"] as? Double,
                  let lowTemp           = temperatureInfo["min"] as? Double,
                  let highTemp          = temperatureInfo["max"] as? Double else { completion(.jsonError); return nil }

            // JSON Parsing to get forecast weather type
            guard let weather = item["weather"] as? [[String:Any]],
                  let id = weather[0]["id"] as? Int,
                  let directType = weather[0]["main"] as? String else { completion(.jsonError); return nil }
            
            let forecast = ForecastWeather()
            forecast.low = lowTemp.kelvinToFarenheit()
            forecast.high = highTemp.kelvinToFarenheit()
            forecast.type = self.weatherTypeForID(weatherID: id)?.rawValue ?? directType.capitalized
            forecast.date = Date(timeIntervalSince1970: date)
            forecasts.append(forecast)
            
        }
        
        return forecasts
        
    }
}
