//
//  ReturnJSON.swift
//  Weather_AppV2
//
//  Created by Adrian Avram on 11/15/17.
//  Copyright © 2017 Adrian Avram. All rights reserved.
//

import Foundation

class ReturnJSON
{
    let group = DispatchGroup()
    var jsonResult : [String : Any]??
    
    func returnJSON (jsonURL: String)
    {
        group.enter()
        let url = URL(string: jsonURL)
        let session = URLSession.shared // or let session = URLSession(configuration: URLSessionConfiguration.default)
        if let usableUrl = url {
            let task = session.dataTask(with: usableUrl, completionHandler: { (data, response, error) in
                if let data = data {
                    self.jsonResult = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    self.group.leave()
                }
            })
            task.resume()
        }
    }
    
    
}
