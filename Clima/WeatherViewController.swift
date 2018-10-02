//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    // API for 5 day forcast is: api.openweathermap.org/data/2.5/forecast?id={city ID}
    // {city ID} is obtainable from List of city ID city.list.json.gz can be downloaded here http://bulk.openweathermap.org/sample/
    let APP_ID = "da1a2f93a00b42cad966a1681df14d17"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var tempScale : String = "Celsius"
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempScaleSwitch: UISwitch!
    
    
    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconDay1: UIImageView!
    @IBOutlet weak var day1Label: UILabel!
    @IBOutlet weak var iconDay2: UIImageView!
    @IBOutlet weak var day2Label: UILabel!
    @IBOutlet weak var iconDay3: UIImageView!
    @IBOutlet weak var day3Label: UILabel!
    @IBOutlet weak var iconDay4: UIImageView!
    @IBOutlet weak var day4Label: UILabel!
    @IBOutlet weak var iconDay5: UIImageView!
    @IBOutlet weak var day5Label: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the basic weather data.")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error : \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    func getForecastData(url : String, parameters : [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Forecast information on-hand!")
                let forecastJSON : JSON = JSON(response.result.value!)
                print(forecastJSON)
                
                self.updateForecastData(json: forecastJSON)
            }
            else {
                print("Error : \(response.result.error)")
                self.forecastLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
     
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue
            
        weatherDataModel.country = json["sys"]["country"].stringValue
            /*print("City: \(weatherDataModel.city) Country: \(weatherDataModel.country)")*/
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        updateUIWithWeatherData()
            
        }
        else {
            cityLabel.text = "Weather unavailable"
        }
    }
    
    //MARK: - Forecast JSON Parsing
    /***************************************************************/
    func updateForecastData(json : JSON) {
        if let fDate = json["list"][0]["dt_txt"].string {
            print("First date returned with forecast is: \(fDate)")
            
            weatherDataModel.date = fDate
            if let fDOW = getDOW(fDate){
              print("Day of Week is : \(fDOW)")
            }else{
                print("bad input")
            }

            
            var fItems : Int = json["cnt"].intValue - 1  /*The number of forecast items to work with*/
            let fDayIncrement : Int = Int((fItems + 1) / 5)
            
            print("Increment for the forecast days is : \(fDayIncrement) for \(fItems) items supplied.")
            
            
             /*for i in 5..1 {
                weatherDataModel.fConditionDay + i = json["list"][(i+i*fDayIncrement)]["weather"][0]["id"].intValue
        
             }*/
             
            
            
            /* Day 5 Information */
            weatherDataModel.fConditionDay5 = json["list"][fItems]["weather"][0]["id"].intValue
            
            print("Forecast Day5 code is: \(json["list"][fItems]["weather"][0]["id"].intValue)")
            
            weatherDataModel.fweatherIconNameDay5 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay5)
            
            print("Day 5 forecast item is : \(fItems)")
            fItems -= fDayIncrement
            print("Day 4 index is : \(fItems)")
            
            
            /* Day 4 Information */
            weatherDataModel.fConditionDay4 = json["list"][fItems]["weather"][0]["id"].intValue
            
            print("Forecast Day4 code is: \(json["list"][fItems]["weather"][0]["id"].intValue)")
            
            weatherDataModel.fweatherIconNameDay4 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay4)
            
            fItems -= fDayIncrement
            print("Day 3 index is : \(fItems)")
            
            
            /* Day 3 Information */
            weatherDataModel.fConditionDay3 = json["list"][fItems]["weather"][0]["id"].intValue
            
            print("Forecast Day3 code is: \(json["list"][fItems]["weather"][0]["id"].intValue)")
            
            weatherDataModel.fweatherIconNameDay3 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay3)
            
            fItems -= fDayIncrement
            print("Day 2 index is : \(fItems)")
            
            
            /* Day 2 Information */
            weatherDataModel.fConditionDay2 = json["list"][fItems]["weather"][0]["id"].intValue
            
            print("Forecast Day2 code is: \(json["list"][fItems]["weather"][0]["id"].intValue)")
            
            weatherDataModel.fweatherIconNameDay2 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay2)
            
            fItems -= fDayIncrement
            print("Day 1 index is : \(fItems)")
            
            
            /* Day 1 Information */
            weatherDataModel.fConditionDay1 = json["list"][fItems]["weather"][0]["id"].intValue
            
            print("Forecast Day1 code is: \(json["list"][fItems]["weather"][0]["id"].intValue)")
            
            weatherDataModel.fweatherIconNameDay1 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay1)
            
            updateUIWithWeatherData()
        }
        else{
            forecastLabel.text = "Forecast Unavailable"
            iconDay1.image = UIImage(named: "null")
            iconDay2.image = UIImage(named: "null")
            iconDay3.image = UIImage(named: "null")
            iconDay4.image = UIImage(named: "null")
            iconDay5.image = UIImage(named: "null")
        }
    }
    //MARK: - Temperature scale selector
    /*************************************************************/
    
    @IBAction func chooseTempScale(_ sender: UISwitch) {
        if tempScaleSwitch.isOn {
            tempScale = "Celsius"
            tempScaleSwitch.setOn(true, animated: true)
            updateUIWithWeatherData()
        }else{
            tempScale = "Fahrenheit"
            tempScaleSwitch.setOn(false, animated: true)
            updateUIWithWeatherData()
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        dateLabel.text = weatherDataModel.date
        cityLabel.text = weatherDataModel.city + ", " + weatherDataModel.country
        
        if tempScale == "Celsius" {
            temperatureLabel.text = "\(weatherDataModel.temperature)°"
            
        }else{
            temperatureLabel.text = "\((weatherDataModel.temperature*9/5)+32)°"
        
        }
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        forecastLabel.text = "5-day Forecast"
        iconDay1.image = UIImage(named: weatherDataModel.fweatherIconNameDay1)
        iconDay2.image = UIImage(named: weatherDataModel.fweatherIconNameDay2)
        iconDay3.image = UIImage(named: weatherDataModel.fweatherIconNameDay3)
        iconDay4.image = UIImage(named: weatherDataModel.fweatherIconNameDay4)
        iconDay5.image = UIImage(named: weatherDataModel.fweatherIconNameDay5)
        
        
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude: \(location.coordinate.longitude), latitude: \(location.coordinate.latitude), Last known altitude: \(location.altitude), course: \(location.course)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
            getForecastData(url : FORECAST_URL, parameters : params)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        getForecastData(url: FORECAST_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    //MARK: - Convert forecast date to day of week
    func getDOW(_ today : String) -> Int? {
        let formatter = DateFormatter()
        let dateIndex = today.firstIndex(of: " ") ?? today.endIndex /*dateIndex sets the character that will split the date/time string (a space in this instance) */
        let datePart = today[..<dateIndex] /*datePart stores the date part of the date/time string */
        print (datePart)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: String(datePart)) else {return nil}
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
}


