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
import Instabug

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast"
//   API for 5 day forcast is: api.openweathermap.org/data/2.5/forecast?id={city ID}
//       {city ID} is obtainable from List of city ID city.list.json.gz can be downloaded here http://bulk.openweathermap.org/sample/
//    Use http://jsoneditoronline.org/ to understand structure of JSON
    let APP_ID = "da1a2f93a00b42cad966a1681df14d17"
    let cityID = "8133876"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    var currentDate: String = ""
    var forecastDates = Array<String>()
    var lowTempsGrouped: [Float] = []
    var highTempsGrouped = [Float]()

    
    var tempScale: String = "Celsius"

    
    //Pre-linked IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempScaleSwitch: UISwitch!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var hTemp: UILabel!
    @IBOutlet weak var lTemp: UILabel!
    
    @IBOutlet weak var wSpeed: UILabel!
    @IBOutlet weak var wGusts: UILabel!
    @IBOutlet weak var wDirection: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!

    @IBOutlet weak var forecastLabel: UILabel!
    
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
//        getWeatherData()
        forecastLabel.isHidden = true
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
//    func getWeather() {
//        let wurl = WEATHER_URL + "?id=" + cityID + "&APPID=" + APP_ID
////        print("wurl = \(wurl)")
//
//        URLSession.shared.dataTask(with: URL(string: wurl)!, completionHandler: { (data, response, error) -> Void in
//            guard let data = data else { return }
//
//            if let error = error {
//                print(error)
//                return
//            }
//
////: FIXME - something below in weatherJSON needs to be defined as well as in the DispatchQueue
//            do {
//                let decoder = JSONDecoder()
//                let weatherJSON = try decoder.decode(something, from: data)
//
//                DispatchQueue.main.async (excute: { () -> Void in
//                    completionHandler(something)
//                })
//            } catch let jsonErr {
//                print(jsonErr)
//            }
//        }).resume()
//    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
//                print("Success! Got the basic weather data.")
                
                let weatherJSON : JSON = JSON(response.result.value!)
//                print("weatherJSON = \n \(weatherJSON)")
                
                self.updateWeatherData(from: weatherJSON)
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
                let forecastJSON: JSON = JSON(response.result.value!)
                print("forecastJSON = \n \(forecastJSON)")
                
//                forecastJSON.array
                
                self.updateForecastData(from: forecastJSON)
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
    func updateWeatherData(from weatherJSON: JSON) {
     
        if let tempResult = weatherJSON["main"]["temp"].float {
            let highTempResult = weatherJSON["main"]["temp_max"].float ?? 0//Added nil-coalescing 10/12/2018
            highTempsGrouped += [highTempResult]
            
            let lowTempResult = weatherJSON["main"]["temp_min"].float ?? 0    //Added nil-coalescing 10/12/2018
            lowTempsGrouped += [lowTempResult]
            print("from updateWeatherData: low: ", lowTempsGrouped, "high: ", highTempsGrouped)
            let pressure = weatherJSON["main"]["pressure"].stringValue
            let humidity = weatherJSON["main"]["humidity"].stringValue
            let wSpeed = weatherJSON["wind"]["speed"].float ?? 0   //Added nil-coalescing 10/12/2018
            let wGust = weatherJSON["wind"]["gust"].float ?? 0     //Added nil-coalescing 10/12/2018
            let wDirection = weatherJSON["wind"]["deg"].int ?? 0   //Added nil-coalescing 10/12/2018
            let dateTime = weatherJSON["dt"].int
            currentDate = returnDate(from: dateTime)

            print("From updateWeatherData, Pressure: \(String(describing:  pressure )), Humidity: \(String(describing: humidity)), Wind Speed: \(String(describing: wSpeed )), Gusting: \(String(describing: wGust )), Wind Direction \(String(describing: wDirection)), Date String \(weatherJSON["dt"]))" )
            
                weatherDataModel.temperature = Int(tempResult - 273.15)
    //FIXME: The high/low temps here represent those for the particular moment that the data was retrieved - the high/low data needs to be extracted from the forecast information and will have to utilize the code for determining the min/max
//                weatherDataModel.hTemp = Int(highTempResult - 273.15)
//                weatherDataModel.lTemp = Int(lowTempResult - 273.15)
            
                weatherDataModel.condition = weatherJSON["weather"][0]["id"].intValue
                weatherDataModel.city = weatherJSON["name"].stringValue
            
                weatherDataModel.country = weatherJSON["sys"]["country"].stringValue
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
    func updateForecastData(from forecastJSON: JSON) {
        
        if let fDateTime = forecastJSON["list"][0]["dt_txt"].string {
//            print("First date returned with forecast is: \(fDate)")
//            let dateIndex = fDateTime.firstIndex(of: " ") ?? fDateTime.endIndex
            let fDate: String = extractDate(from: fDateTime)

            if let fDOW = getDOW(from: fDate){
              weatherDataModel.date = currentDate + ", " + weatherDataModel.dayNames[fDOW]
//                weatherDataModel.date = fDate + ", " + dayNames[fDOW]
//                print(weatherDataModel.date)
//                print("Day of Week is : \(dayNames[fDOW]) and the date is \(fDate)")
            }else{
                print("bad input")
            }
            /*:
             fItems is the number of forecast items to work with
             */
            var fItems: Int = forecastJSON["cnt"].intValue - 1
            var lowTemps = [Float]()
            var highTemps = [Float]()
            print("forecast items retrieved: ", fItems)
            
            //MARK: Form the forecastDates array from the json data
            for item in 0...fItems {
                let dateString = String(returnDate(from: forecastJSON["list"][item]["dt"].int))
                forecastDates += [dateString]
                if let lowTemp = forecastJSON["list"][item]["main"]["temp_min"].float {
                    lowTemps += [lowTemp]
                }
                if let highTemp = forecastJSON["list"][item]["main"]["temp_max"].float {
                    highTemps += [highTemp]
                }
            }
            print("forecastDates from updateForecastData: ", forecastDates, forecastDates.count, "\n", lowTemps, lowTemps.count, "\n", highTemps, highTemps.count)
            
            //MARK: Group high/low temp info by date and compute high/low temps for weather/forecast date range
            var minMaxTempsByDay = [Float]()
            var rangeDate = currentDate
            
            for (i, forecastDate) in forecastDates.enumerated() {
                if rangeDate == forecastDate {
                    lowTempsGrouped += [lowTemps[i]]
                    highTempsGrouped += [highTemps[i]]
                } else {
                    minMaxTempsByDay += [lowTempsGrouped.min()!, highTempsGrouped.max()!]
                    print(lowTempsGrouped, highTempsGrouped, minMaxTempsByDay)
                    
                    lowTempsGrouped = []
                    highTempsGrouped = []
                    lowTempsGrouped += [lowTemps[i]]
                    highTempsGrouped += [highTemps[i]]
                    rangeDate = forecastDate
                }
                print(i, forecastDate)
            }
            minMaxTempsByDay += [lowTempsGrouped.min()!, highTempsGrouped.max()!]
            print(minMaxTempsByDay, lowTempsGrouped, lowTempsGrouped.min()!, highTempsGrouped.max()!)
/*:
 20180409 Moved from updateWeatherData as high/low temp data is dependent on forecast information and makes more sense to reside here.  Additionally, the minMaxTempsByDay array immediately preceeds this assignment.
 */
            weatherDataModel.lTemp = Int(minMaxTempsByDay[0] - 273.15)
            weatherDataModel.hTemp = Int(minMaxTempsByDay[1] - 273.15)
            
            let fDayIncrement : Int = Int((fItems + 1) / 5)
            forecastLabel.isHidden = false
            dateLabel.isHidden = false
            day1Label.isHidden = false
            day2Label.isHidden = false
            day3Label.isHidden = false
            day4Label.isHidden = false
            day5Label.isHidden = false
//            print("Increment for the forecast days is : \(fDayIncrement) for \(fItems) items supplied.")
            
            
            //MARK: Day 5 Information
            weatherDataModel.fConditionDay5 = forecastJSON["list"][fItems]["weather"][0]["id"].intValue
            weatherDataModel.fweatherIconNameDay5 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay5)
            print("Day 5 date string: ",forecastJSON["list"][fItems]["dt_txt"].stringValue)
            day5Label.text = weatherDataModel.dayNames[getDOW(from: forecastJSON["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day5 code is: \(weatherDataModel.fConditionDay5) for \(String(describing: day5Label.text))")
//
//            print("Day 5 forecast item is : \(fItems)")
            fItems -= fDayIncrement
//            print("Day 4 index is : \(fItems)")
            
            //MARK: Day 4 Information
            weatherDataModel.fConditionDay4 = forecastJSON["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay4 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay4)
            
            day4Label.text = weatherDataModel.dayNames[getDOW(from: forecastJSON["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day4 code is: \(weatherDataModel.fConditionDay4) for \(String(describing: day4Label.text))")
            
            fItems -= fDayIncrement
//            print("Day 3 index is : \(fItems)")
            
            //MARK: Day 3 Information
            weatherDataModel.fConditionDay3 = forecastJSON["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay3 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay3)
            
            day3Label.text = weatherDataModel.dayNames[getDOW(from: forecastJSON["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day3 code is: \(weatherDataModel.fConditionDay3) for \(String(describing: day3Label.text))")
            
            fItems -= fDayIncrement
//            print("Day 2 index is : \(fItems)")
            
            //MARK: Day 2 Information
            weatherDataModel.fConditionDay2 = forecastJSON["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay2 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay2)
            
            day2Label.text = weatherDataModel.dayNames[getDOW(from: forecastJSON["list"][fItems]["dt_txt"].stringValue)!]
            
//            print("Forecast Day2 code is: \(weatherDataModel.fConditionDay2) for \(String(describing: day2Label.text))")
            fItems -= fDayIncrement
//            print("Day 1 index is : \(fItems)")
            
            //MARK: Day 1 Information
            weatherDataModel.fConditionDay1 = forecastJSON["list"][fItems]["weather"][0]["id"].intValue
            
            weatherDataModel.fweatherIconNameDay1 = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.fConditionDay1)
            
            day1Label.text = weatherDataModel.dayNames[getDOW(from: forecastJSON["list"][fItems]["dt_txt"].stringValue)!]
            
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
        let windSpeed = Int(weatherDataModel.wSpeed*3.6)
        let windGusts = Int(weatherDataModel.wGust*3.6)
        wSpeed.text = "\(windSpeed) kph"
        wGusts.text = "\(windGusts) kph"
        wDirection.text = "\(weatherDataModel.wDirection)°"
        humidity.text = weatherDataModel.humidity + "%"
        pressure.text = weatherDataModel.pressure + " hPa"
        
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
            
            print("From locationManager longitude: \(location.coordinate.longitude), latitude: \(location.coordinate.latitude), Last known altitude: \(location.altitude), course: \(location.course)")
            
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
    func getDOW(from fdate: String) -> Int? {
        let formatter = DateFormatter()
        let dateIndex = fdate.firstIndex(of: " ") ?? fdate.endIndex /*dateIndex sets the character that will split the date/time string (a space in this instance) */
        let datePart = fdate[..<dateIndex] /*datePart stores the date part of the date/time string */
//        print (datePart)
//        let datePart = extractDate(today)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: String(datePart)) else {return nil}
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    // MARK: Convert timeInterval to date
    func returnDate(from timeInterval: Int?) -> String {
        guard let timeInterval = timeInterval else { fatalError() }
        let date = NSDate.init(timeIntervalSince1970: TimeInterval(timeInterval)).description.components(separatedBy: " ").first!
        return date
    }
    
    
    func extractDate(from dateTime: String) -> String {
        /*:
         An alternative way of retreiving the date from the entire date/time string follows in the print statement below.
         */
//        print("from extractDate: dateFromString: ", dateTime.components(separatedBy: " ").first!)
        let dateIndex = dateTime.firstIndex(of: " ") ?? dateTime.endIndex
        /*:
         dateIndex sets the character that will split the date/time string (a space in this instance)
         */
        let fDate = dateTime[..<dateIndex]
        
        print("from extractDate, fDate: ",fDate)
        
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


