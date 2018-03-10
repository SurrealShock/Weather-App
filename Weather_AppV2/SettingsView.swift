//
//  SettingsView.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/18/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import UIKit

class SettingsView: UITableViewController {
    @IBOutlet weak var fahrenheitCell: UITableViewCell!
    @IBOutlet weak var celsiusCell: UITableViewCell!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateCell: UITableViewCell!
    var saveCity = [SaveCity]()
    let userData = UserData()
    var reply = ""
    let unitKey = "c/f"
    let dateKey = "userDate"
    var sorted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        reply = userData.getUserData(key: unitKey)
        if (reply == "f") {
            fahrenheitCell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            celsiusCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        reply = userData.getUserData(key: dateKey)
        if (reply == "EEEE M/dd") {
            dateCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        saveCity = MySQLite.instance.getCity()
        cityLabel.text = String(saveCity.count) + " favorited cities"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var newIndexPath = indexPath
        var unit = tableView.cellForRow(at: newIndexPath)
        
        reply = userData.getUserData(key: unitKey)
        // If fahrenheit is pressed and then celsius is pressed, uncheck fahrenheit and check celsius
        
        switch newIndexPath.section {
        case 0:
            if(reply == "f" && newIndexPath[1] == 1) {
                unit?.accessoryType = UITableViewCellAccessoryType.checkmark
                newIndexPath[1] = 0
                unit = tableView.cellForRow(at: newIndexPath)
                unit?.accessoryType = UITableViewCellAccessoryType.none
                userData.saveUserData(key: unitKey, value: "c")
            } else if (reply == "c" && newIndexPath[1] == 0) {
                unit?.accessoryType = UITableViewCellAccessoryType.checkmark
                newIndexPath[1] = 1
                unit = tableView.cellForRow(at: newIndexPath)
                unit?.accessoryType = UITableViewCellAccessoryType.none
                userData.saveUserData(key: unitKey, value: "f")
            }
        case 1:
            if(newIndexPath.row == 0) {
                saveCity = MySQLite.instance.getCity()
                cityLabel.text = "0 favorited cities"
                if saveCity.count != 0 {
                    for index in 0 ... saveCity.count-1 {
                        let id = MySQLite.instance.deleteCity(cid: saveCity[index].id!)
                        if(!id) {
                            let alertController = UIAlertController(title: "Error", message: "There was an issue deleting a favorited city.", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            break;
                        }
                    }
                }
            } else if (newIndexPath.row == 1 && !sorted) {
                MySQLite.instance.sortCity()
                sorted = true
            }
        case 2:
            reply = userData.getUserData(key: dateKey)
            if(newIndexPath.row == 0) {
                if(reply == "EEEE M/dd") {
                    userData.saveUserData(key: dateKey, value: "EEEE")
                    dateCell.accessoryType = UITableViewCellAccessoryType.none
                } else {
                    userData.saveUserData(key: dateKey, value: "EEEE M/dd")
                    dateCell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
        default:
            print("Could not load settings")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
