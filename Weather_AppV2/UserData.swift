//
//  UserData.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/18/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import Foundation

let preferences = UserDefaults.standard

class UserData {
    
    let apiKeyClass = Constant()
    
    func saveUserData(key: String, value: String ){
        preferences.set(value, forKey: key)
    }
    
    func getUserData(key: String) -> String {
        if(key == "c/f"){
            if preferences.object(forKey: key) == nil{
                preferences.set("f", forKey: key)
            }
        }
        if(key == "url"){
            if preferences.object(forKey: key) == nil{
                preferences.set("https://api.openweathermap.org/data/2.5/weather?lat=40.7128&lon=-74.0060" + apiKeyClass.weather_key, forKey: key)
            }
        }
        if(key == "predictionURL"){
            if preferences.object(forKey: key) == nil{
                preferences.set("https://api.openweathermap.org/data/2.5/forecast/daily?lat=40.7128&lon=-74.0060&cnt=6" + apiKeyClass.weather_key, forKey: key)
            }
        }
        if(key == "currCity"){
            if preferences.object(forKey: key) == nil{
                preferences.set("New York", forKey: key)
            }
        }
        
        if(key == "userDate"){
            if preferences.object(forKey: key) == nil{
                preferences.set("EEEE M/dd", forKey: key)
            }
        }
        return preferences.string(forKey: key)!
    }
}
