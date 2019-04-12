//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Angela Yu on 24/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class WeatherDataModel {

    //Declare your model variables here
    var temperature: Int = 0
    var hTemp: Int = 0
    var lTemp: Int = 0
    var condition: Int = 0
    var city: String = ""
    var country: String = ""
    var weatherIconName: String = ""
    var date: String = ""
    
    var pressure: String = ""
    var humidity: String = ""
    var wSpeed: Float = 0
    var wGust: Float = 0
    var wDirection: Int = 0
    // MARK: - Forecast Consditons for respective days
    var fConditionDay1: Int = 0
    var fConditionDay2: Int = 0
    var fConditionDay3: Int = 0
    var fConditionDay4: Int = 0
    var fConditionDay5: Int = 0
    // MARK: - Forecast Icons for respective days
    var fweatherIconNameDay1: String = ""
    var fweatherIconNameDay2: String = ""
    var fweatherIconNameDay3: String = ""
    var fweatherIconNameDay4: String = ""
    var fweatherIconNameDay5: String = ""
    
    let dayNames = ["","SUN","MON","TUE","WED","THU","FRI","SAT"]
    
    
    //MARK: - The updateWeatherIcon method turns a condition code into the name of the weather condition image icon
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
        
            case 0...300 :
                return "tstorm1"
            
            case 301...500 :
                return "light_rain"
            
            case 501...600 :
                return "shower3"
            
            case 601...700 :
                return "snow4"
            
            case 701...771 :
                return "fog"
            
            case 772...799 :
                return "tstorm3"
            
            case 800 :
                return "sunny"
            
            case 801...804 :
                return "cloudy2"
            
            case 900..<903, 905...1000 :
                return "tstorm3"
            
            case 903 :
                return "snow5"
            
            case 904 :
                return "sunny"
            
            default :
                return "dunno"
        }
    }
}
