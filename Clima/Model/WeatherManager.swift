//
//  WeatherManager.swift
//  Clima
//
//  Created by Ayberk Aktürk on 15.03.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=f17f25817fbcde60e686e533407e2da1&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(_ cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(_ lattitude: CLLocationDegrees, _ longitude : CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(lattitude)&lon=\(longitude)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlSring: String) {
        if let url = URL(string: urlSring){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){(data, response, error) in
                if error != nil{
                    delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from : weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    

}

