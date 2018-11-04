//
//  WeatherViewController.swift
//  WeatherApp
//
//  Original project Created by Angela Yu on 23/08/2015.
//  Embellishments by William Spanfelner 26/10/2018
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
//   API for 5 day forcast is: api.openweathermap.org/data/2.5/forecast?id={city ID}
//       {city ID} is obtainable from List of city ID city.list.json.gz can be downloaded here http://bulk.openweathermap.org/sample/
//    Use http://jsoneditoronline.org/ to understand structure of JSON
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
    
    @IBOutlet weak var hTemp: UILabel!
    @IBOutlet weak var lTemp: UILabel!
    
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
    
    
    @IBOutlet weak var wSpeed: UILabel!
    @IBOutlet weak var wGusts: UILabel!
    @IBOutlet weak var wDirection: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastLabel.isHidden = true
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
//                print("Success! Got the basic weather data.")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error : \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    func getForecastData(url : String, parameters : [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
//                print("Forecast information on-hand!")
                let forecastJSON : JSON = JSON(response.result.value!)
                print(forecastJSON)
                
                self.updateForecastData(json: forecastJSON)
            }
            else {
                print("Error : \(String(describing: response.result.error))")
                self.forecastLabel.text = "Connection Issues"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
     
        if let tempResult = json["main"]["temp"].double {
            let highTempResult = json["main"]["temp_max"].double
            let lowTempResult = json["main"]["temp_min"].double
            let pressure = json["main"]["pressure"].stringValue
            let humidity = json["main"]["humidity"].stringValue
            let wSpeed = json["wind"]["speed"].stringValue
            let wGust = json["wind"]["gust"].stringValue
            let wDirection = json["wind"]["deg"].stringValue
            
            print("Pressure: \(String(describing:  pressure )), Humidity: \(String(describing: humidity)), Wind Speed: \(String(describing: wSpeed )), Gusting: \(String(describing: wGust )), Wind Direction \(String(describing: wDirection ))" )
            
                weatherDataModel.temperature = Int(tempResult - 273.15)
    //FIXME: The high/low temps here represent those for the particular moment that the data was retrieved - the high/low data needs to be extracted from the forecast information and will have to utilize the code for determining the min/max
                weatherDataModel.hTemp = Int(highTempResult! - 273.15)
                weatherDataModel.lTemp = Int(lowTempResult! - 273.15)
            
                weatherDataModel.condition = json["weather"][0]["id"].intValue
                weatherDataModel.city = json["name"].stringValue
            
                weatherDataModel.country = json["sys"]["country"].stringValue
                    /*print("City: \(weatherDataModel.city) Country: \(weatherDataModel.country)")*/
            
                weatherDataModel.wSpeed = wSpeed
                weatherDataModel.wGust = wGust
                weatherDataModel.wDirection = wDirection
                weatherDataModel.humidity = humidity
                weatherDataModel.pressure = pressure
            
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
        let dayNames = ["","SUN","MON","TUE","WED","THU","FRI","SAT"]
        
        if let fDateTime = json["list"][0]["dt_txt"].string {
//            print("First date returned with forecast is: \(fDate)")
//            let dateIndex = fDateTime.firstIndex(of: " ") ?? fDateTime.endIndex /*dateIndex sets the character that will split the date/time          string (a space in this instance) */
            let fDate = extractDate(fDateTime)
            
            if let fDOW = getDOW(String(fDate)){
              weatherDataModel.date = fDate + ", " + dayNames[fDOW]
//                print(weatherDataModel.date)
//                print("Day of Week is : \(dayNames[fDOW]) and the date is \(fDate)")
            }else{
                print("bad input")
            }

            
            var fItems : Int = json["cnt"].intValue - 1  /*The number of forecast items to work with*/
            let fDayIncrement : Int = Int((fItems + 1) / 5)
            forecastLabel.isHidden = false
            dateLabel.isHidden = false
            day1Label.isHidden = false
            day2Label.isHidden = false
            day3Label.isHidden = false
            day4Label.isHidden = false
            day5Label.isHidden = false
//            print("Increment for the forecast days is : \(fDayIncrement) for \(fItems) items supplied.")
            
            
            
            /* Day 5 Information */
            weatherDataModel.fConditionDay5 = json["list"][fItems]["weather"][0]["id"].intValue
            weatherDataModel.fweatherIconNameDay5 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay5)
            
            day5Label.text = dayNames[getDOW(json["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day5 code is: \(weatherDataModel.fConditionDay5) for \(String(describing: day5Label.text))")
//
//            print("Day 5 forecast item is : \(fItems)")
            fItems -= fDayIncrement
//            print("Day 4 index is : \(fItems)")
            
            
            /* Day 4 Information */
            weatherDataModel.fConditionDay4 = json["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay4 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay4)
            
            day4Label.text = dayNames[getDOW(json["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day4 code is: \(weatherDataModel.fConditionDay4) for \(String(describing: day4Label.text))")
            
            fItems -= fDayIncrement
//            print("Day 3 index is : \(fItems)")
            
            
            /* Day 3 Information */
            weatherDataModel.fConditionDay3 = json["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay3 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay3)
            
            day3Label.text = dayNames[getDOW(json["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day3 code is: \(weatherDataModel.fConditionDay3) for \(String(describing: day3Label.text))")
            
            fItems -= fDayIncrement
//            print("Day 2 index is : \(fItems)")
            
            
            /* Day 2 Information */
            weatherDataModel.fConditionDay2 = json["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay2 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay2)
            
            day2Label.text = dayNames[getDOW(json["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day2 code is: \(weatherDataModel.fConditionDay2) for \(String(describing: day2Label.text))")
            fItems -= fDayIncrement
//            print("Day 1 index is : \(fItems)")
            
            
            /* Day 1 Information */
            weatherDataModel.fConditionDay1 = json["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay1 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay1)
            
            day1Label.text = dayNames[getDOW(json["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day1 code is: \(weatherDataModel.fConditionDay1) for \(String(describing: day1Label.text))")
            
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
        cityLabel.text = weatherDataModel.city + ", " + weatherDataModel.country /* + ", " weatherDataModel. */
        wSpeed.text = weatherDataModel.wSpeed + "m/s"
        wGusts.text = weatherDataModel.wGust + "m/s"
        wDirection.text = weatherDataModel.wDirection + "°"
        humidity.text = weatherDataModel.humidity + "%"
        pressure.text = weatherDataModel.pressure + "hPa"
        
        if tempScale == "Celsius" {
            temperatureLabel.text = "\(weatherDataModel.temperature)°"
            hTemp.text = "\(weatherDataModel.hTemp)°"
            lTemp.text = "\(weatherDataModel.lTemp)°"
        }else{
            temperatureLabel.text = "\((weatherDataModel.temperature*9/5)+32)°"
            hTemp.text = "\((weatherDataModel.hTemp*9/5)+32)°"
            lTemp.text = "\((weatherDataModel.lTemp*9/5)+32)°"
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
        forecastLabel.isHidden = true
        dateLabel.isHidden = true
        day1Label.isHidden = true
        day2Label.isHidden = true
        day3Label.isHidden = true
        day4Label.isHidden = true
        day5Label.isHidden = true
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
//        print (datePart)
//        let datePart = extractDate(today)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: String(datePart)) else {return nil}
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func extractDate (_ dateTime : String) -> String {

        let dateIndex = dateTime.firstIndex(of: " ") ?? dateTime.endIndex /*dateIndex sets the character that will split the date/time string (a space in this instance) */
        let fDate = dateTime[..<dateIndex]
        
        print (fDate)
        
        return String(fDate)
    }
    
    //TODO: Use the minMax function below from the Swift 4.2 manual to determine High & Low Forecast Temps
//    func minMax(array: [Int]) -> (min: Int, max: Int)? {
//        if array.isEmpty { return nil }
//        var currentMin = array[0]
//        var currentMax = array[0]
//        for value in array[1..<array.count] {
//            if value < currentMin {
//                currentMin = value
//            } else if value > currentMax {
//                currentMax = value
//            }
//        }
//        return (currentMin, currentMax)
//    }
    
    
    //TODO: Idea to add wind direction to the clima app.
}


