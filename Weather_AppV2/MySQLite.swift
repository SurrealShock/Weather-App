//
//  MySQLite.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/23/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import SQLite

class MySQLite {
    static let instance = MySQLite()
    private let db: Connection?
    
    private let saveCity = Table("SaveCity")
    private let id = Expression<Int64>("id")
    private let city = Expression<String?>("city")
    private let cityURL = Expression<String>("cityURL")
    private let cityPredictionURL = Expression<String>("cityPredictionURL")
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/MySQLite.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(saveCity.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(city, unique: true)
                table.column(cityURL, unique: true)
                table.column(cityPredictionURL, unique: true)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addCity(ccity: String, ccityURL: String, ccityPredictionURL: String) -> Int64? {
        do {
            let insert = saveCity.insert(city <- ccity, cityURL <- ccityURL, cityPredictionURL <- ccityPredictionURL)
            let id = try db!.run(insert)
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }

    func deleteCity(cid: Int64) -> Bool {
        do {
            let CS = saveCity.filter(id == cid)
            try db!.run(CS.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func sortCity(){
        var SC = getCity()
        var cityArray = [""]
        if SC.count != 0 {
            cityArray.removeLast()
            for index in 0 ... SC.count-1 {
                cityArray.append(SC[index].city)
            }
            
            var city : String
            var cityURL : String
            var cityPredictionURL : String
            cityArray = cityArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            for y in 0 ... cityArray.count-1 {
                for x in 0 ... cityArray.count-1 {
                    SC = getCity()
                    if (cityArray[y] == SC[x].city) {
                        city = SC[x].city
                        cityURL = SC[x].cityURL
                        cityPredictionURL = SC[x].cityPredictionURL
                        let id = deleteCity(cid: SC[x].id!)
                        if(id) {
                            let cityID = addCity(ccity: city, ccityURL: cityURL, ccityPredictionURL: cityPredictionURL)
                            if(cityID == -1) {
                                break;
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func getCity() -> [SaveCity] {
        var SC = [SaveCity]()
        
        do {
            for index in try db!.prepare(self.saveCity) {
                SC.append(SaveCity(
                    id: index[id],
                    city: index[city]!,
                    cityURL: index[cityURL],
                    cityPredictionURL: index[cityPredictionURL]))
            }
        } catch {
            print("Select failed")
        }
        
        return SC
    }

}
