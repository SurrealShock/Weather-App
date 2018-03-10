//
//  ViewController.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/15/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import UIKit
import GooglePlaces
import Crashlytics

class ViewController: UIViewController {
    
    @IBOutlet weak var starButton: UIBarButtonItem!
    @IBOutlet weak var sunsetView: UILabel!
    @IBOutlet weak var sunriseView: UILabel!
    @IBOutlet weak var cityView: UILabel!
    @IBOutlet weak var temperatureView: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var humidityView: UILabel!
    @IBOutlet weak var skyView: UILabel!
    @IBOutlet weak var visibilityView: UILabel!
    @IBOutlet weak var windspeedView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let impact = UIImpactFeedbackGenerator()
    var starOpen = true
    var currIndex = -1
    var currCityName = "null"
    var saveCity = [SaveCity]()
    var dateSett = ""
    var getNewCity = true
    var lastCurrWeather : [String : Any]??
    var lastPredictWeather : [String : Any]??
    var tempUnit = ""
    var getJSONData = ReturnJSON()
    var weatherURL = ""
    var forecastURL = ""
    var weatherURLBeginning = "https://api.openweathermap.org/data/2.5/weather?"
    var forecastURLBeginning = "https://api.openweathermap.org/data/2.5/forecast/daily?"
    let apiKeyClass = Constant()
    var apiKey = ""
    let dateFormatter = DateFormatter()
    let userData = UserData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiKey = apiKeyClass.weather_key
        self.title = "Weather"
        saveCity = MySQLite.instance.getCity()
        loadingView.stopAnimating()
        loadingView.hidesWhenStopped = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**** When the search is pressed create a fullscreen view of the autocomplete API ****/
    @IBAction func searchButton(_ sender: Any) {
        makeSearch()
    }
    
    func makeSearch() {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.autocompleteFilter = filter
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(getNewCity) {
            getData()
            getNewCity = false
        } else if(tempUnit != userData.getUserData(key: "c/f") || dateSett != userData.getUserData(key: "userDate")) {
            tempUnit = userData.getUserData(key: "c/f")
            dateSett = userData.getUserData(key: "userDate")
            updateTodayView(jsonVAL: lastCurrWeather)
            updatePredictionView(jsonVAL: lastPredictWeather)
        }
        
        starButton.image = #imageLiteral(resourceName: "star_open")
        starOpen = true
        saveCity = MySQLite.instance.getCity()
        if(saveCity.count != 0) {
            for index in 0 ... saveCity.count-1 {
                if(saveCity[index].city == currCityName) {
                    starButton.image = #imageLiteral(resourceName: "star_closed")
                    starOpen = false
                    currIndex = index
                    break
                }
            }
        }
    }
    
    func getData()
    {
        loadingView.startAnimating() // Start the loading animation
        /**** Call the function to return data from the JSON URL ****/
        getJSONData.returnJSON(jsonURL: self.userData.getUserData(key: "url"))
        getJSONData.group.notify(queue: .main) {
            self.lastCurrWeather = self.getJSONData.jsonResult
            self.updateTodayView(jsonVAL: self.lastCurrWeather) // Update the view with the new values
            self.getPredictionData()
        }
    }
    func getPredictionData()
    {
        getJSONData.returnJSON(jsonURL: self.userData.getUserData(key: "predictionURL"))
        getJSONData.group.notify(queue: .main) {
            self.lastPredictWeather = self.getJSONData.jsonResult
            self.updatePredictionView(jsonVAL: self.lastPredictWeather) // Update the view with the new values
            self.loadingView.stopAnimating()
        }
    }
    
    
    @IBAction func dropDownMenu(_ sender: Any) {
        impact.impactOccurred()
        saveCity = MySQLite.instance.getCity()
        
        if saveCity.count != 0 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for index in 0 ... saveCity.count-1 {
                alert.addAction(UIAlertAction(title: saveCity[index].city, style: .default) { _ in
                    self.userData.saveUserData(key: "currCity", value: self.saveCity[index].city)
                    self.userData.saveUserData(key: "url", value: self.saveCity[index].cityURL)
                    self.userData.saveUserData(key: "predictionURL", value: self.saveCity[index].cityPredictionURL)
                    self.getData()
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "No favorited cities", message: "Favorite a city by pressing on the star", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction (title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func starCity(_ sender: Any) {
        impact.impactOccurred()
        if(starOpen) {
            let city = currCityName
            let cityURL = userData.getUserData(key: "url")
            let cityPredictionURL = userData.getUserData(key: "predictionURL")
            let id = MySQLite.instance.addCity(ccity: city, ccityURL: cityURL, ccityPredictionURL: cityPredictionURL)
            if(id != -1) {
                self.starButton.image = #imageLiteral(resourceName: "star_closed")
                starOpen = false
            }
        } else {
            print(currIndex)
            let id = MySQLite.instance.deleteCity(cid: saveCity[currIndex].id!)
            if(id) {
                starButton.image = #imageLiteral(resourceName: "star_open")
                starOpen = true
            }
        }
        saveCity = MySQLite.instance.getCity()
        if(saveCity.count != 0) {
            for index in 0 ... saveCity.count-1 {
                if(saveCity[index].city == currCityName) {
                    currIndex = index
                    break
                }
            }
        }
    }
    
    
    func getWeatherImage(currTime : Double, sunset : Double, sunrise : Double, weatherID : Int) -> UIImage
    {
        let returnImage : UIImage
        switch weatherID {
        case 200 ... 232:
            returnImage = #imageLiteral(resourceName: "thunder_cloud_rain")
        case 300 ... 321:
            returnImage = #imageLiteral(resourceName: "dark_rain_cloud")
        case 500 ... 531:
            if (sunrise < currTime && currTime < sunset) {
                returnImage = #imageLiteral(resourceName: "sunny_rain_cloud")
            } else {
                returnImage = #imageLiteral(resourceName: "night_rain_cloud")
            }
        case 600 ... 622:
            returnImage = #imageLiteral(resourceName: "snow_cloud")
        case 701 ... 781:
            if (sunrise < currTime && currTime < sunset) {
                returnImage = #imageLiteral(resourceName: "day_smoke_cloud")
            } else {
                returnImage = #imageLiteral(resourceName: "night_smoke_cloud")
            }
        case 800:
            returnImage = #imageLiteral(resourceName: "Sun")
        case 801:
            if (sunrise < currTime && currTime < sunset) {
                returnImage = #imageLiteral(resourceName: "sun_cloud")
            } else {
                returnImage = #imageLiteral(resourceName: "night_cloud")
            }
        case 802:
            returnImage = #imageLiteral(resourceName: "cloud")
        case 803, 804:
            returnImage = #imageLiteral(resourceName: "dark_cloud")
        default:
            returnImage = #imageLiteral(resourceName: "unknown")
        }
        
        return returnImage
    }
    
    func updatePredictionView (jsonVAL : [String : Any]??)
    {
        let reply = userData.getUserData(key: "c/f")
        let newJSONVAL = jsonVAL!!
        dateFormatter.dateFormat = userData.getUserData(key: "userDate")
        var predictionImageView : UIImageView
        var jsonP : [String : Any]
        var temp1 : Double
        var temp2 : Double
        var label : UILabel
        var jsonArray = newJSONVAL["list"] as! [[String: Any]]
        var weatherArray : [[String : Any]]
        
        for index in 1...5 {
            let dt = Double(truncating: jsonArray[index]["dt"] as! NSNumber)
            let date = NSDate(timeIntervalSince1970: dt)
            let dateString = dateFormatter.string(from: date as Date)
            label = (self.view.viewWithTag(index+5) as? UILabel)!
            label.text = dateString
            
            jsonP = jsonArray[index]["temp"] as! [String : Any]
            temp1 = Double(truncating: jsonP["min"] as! NSNumber)
            temp2 = Double(truncating: jsonP["max"] as! NSNumber)
            if(reply == "f") {
                temp1 = 9 / 5 * (temp1 - 273) + 32
                temp2 = 9 / 5 * (temp2 - 273) + 32
            }
            else {
                temp1 = temp1 - 273.15
                temp2 = temp2 - 273.15
            }
            label = (self.view.viewWithTag(index + 10) as? UILabel)!
            label.text = String(format: "%.1f", temp1) + "° / " + String(format: "%.1f", temp2) + "°"
            
            weatherArray = jsonArray[index]["weather"] as! [[String : Any]]
            let imageID = Int(truncating: weatherArray[0]["id"] as! NSNumber)
            predictionImageView = (self.view.viewWithTag(index) as? UIImageView)!
            predictionImageView.image = getWeatherImage(currTime: 1, sunset: 2, sunrise: 0, weatherID: imageID)
            
            let weatherLabel = String(weatherArray[0]["description"] as! NSString).capitalized
            label = (self.view.viewWithTag(index + 15) as? UILabel)!
            label.text = weatherLabel
        }
    }
    
    func updateTodayView(jsonVAL : [String: Any]??){
        
        let reply = userData.getUserData(key: "c/f")
        /**** Get the name of the city that the user chose ****/
        var newJSONVal = jsonVAL!!
        if(currCityName == "null") {
            currCityName = userData.getUserData(key: "currCity")
        }
        currCityName = userData.getUserData(key: "currCity")
        self.cityView.text = currCityName
        
        starButton.image = #imageLiteral(resourceName: "star_open")
        starOpen = true
        if(saveCity.count != 0) {
            for index in 0 ... saveCity.count-1 {
                if(saveCity[index].city == currCityName) {
                    starButton.image = #imageLiteral(resourceName: "star_closed")
                    starOpen = false
                    currIndex = index
                    break
                }
            }
        }
        
        /**** Get visiblity in miles ****/
        var visibility: Int
        if let visibilityNS = newJSONVal["visibility"] as? NSNumber {
            visibility = visibilityNS.intValue
        } else {
            visibility = -1
        }
        
        /**** Get the current temperature outside ****/
        var jsonP = newJSONVal["main"] as! [String: Any]
        let currTempNS = jsonP["temp"] as! NSNumber
        var currTemp : Double = Double(truncating: currTempNS)
        
        /**** Get the wind speed in m/s. Convert to double and change units ****/
        jsonP = newJSONVal["wind"] as! [String: Any]
        var windSpeed = Double(truncating: jsonP["speed"] as! NSNumber)
        
        
        if(reply == "f")
        {
            currTemp = 9/5 * (currTemp-273) + 32
            
            if (visibility != -1) {
                visibility = visibility/1609
                visibilityView.text = "\(visibility) miles"
            } else {
                visibilityView.text = "--"
            }
            
            windSpeed = windSpeed * 25 / 11
            windspeedView.text = String(format: "%.1f", windSpeed) + " mph"
        }
        else
        {
            currTemp = currTemp - 273.15
            
            if (visibility != -1) {
                visibility = visibility/1000
                visibilityView.text = "\(visibility) km"
            } else {
                visibilityView.text = "--"
            }
            windspeedView.text = String(format: "%.1f", windSpeed) + " m/s"
        }
        self.temperatureView.text = String(format: "%.1f", currTemp) + "°"
        /**** Get the current humidity as a % ****/
        jsonP = newJSONVal["main"] as! [String: Any]
        let currHumidityNS = jsonP["humidity"] as! NSNumber
        self.humidityView.text = "\(String(describing: currHumidityNS))%"
        
        /**** Get the sunrise time in unix ****/
        jsonP = newJSONVal["sys"] as! [String: Any]
        let sunrise = Double(truncating: jsonP["sunrise"] as! NSNumber)
        
        /**** Format the unix time to be a readable format ****/
        dateFormatter.dateFormat = "h:mm a"
        var date = NSDate(timeIntervalSince1970: sunrise)
        var dateString = dateFormatter.string(from: date as Date)
        sunriseView.text = dateString
        
        /**** Get the sunset time and convert it to a readable value ****/
        let sunset = Double(truncating: jsonP["sunset"] as! NSNumber)
        date = NSDate(timeIntervalSince1970: sunset)
        dateString = dateFormatter.string(from: date as Date)
        sunsetView.text = dateString
        
        /**** Get the current weather status from a JSON array ****/
        var jsonArray = newJSONVal["weather"] as! [[String: Any]]
        let currTime = NSDate().timeIntervalSince1970

        let weatherID = Int(truncating: jsonArray[0]["id"] as! NSNumber)
        skyView.text = String(describing: jsonArray[0]["description"]!).capitalized
        
        /**** Use the weatherID and what time it is to pick an image ****/
        imageView.image = getWeatherImage(currTime: currTime, sunset: sunset, sunrise: sunrise, weatherID: weatherID)
    }
}



extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        currCityName = place.name
        userData.saveUserData(key: "currCity", value: currCityName)
        weatherURL = "\(weatherURLBeginning)lat=\(place.coordinate.latitude)&lon=\(place.coordinate.longitude)\(apiKey)"
        forecastURL = "\(forecastURLBeginning)lat=\(place.coordinate.latitude)&lon=\(place.coordinate.longitude)&cnt=6\(apiKey)"
        userData.saveUserData(key: "url", value: weatherURL)
        userData.saveUserData(key: "predictionURL", value: forecastURL)
        getNewCity = true
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

