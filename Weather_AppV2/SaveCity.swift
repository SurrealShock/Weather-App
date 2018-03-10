//
//  SaveCity.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/23/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import Foundation

class SaveCity {
     let id: Int64?
    var city : String
    var cityURL : String
    var cityPredictionURL : String
    
    init(id: Int64) {
        self.id = id
        city = ""
        cityURL = ""
        cityPredictionURL = ""
    }
    
    init(id: Int64, city: String, cityURL: String, cityPredictionURL: String) {
        self.id = id
        self.city = city
        self.cityURL = cityURL
        self.cityPredictionURL = cityPredictionURL
    }
}
