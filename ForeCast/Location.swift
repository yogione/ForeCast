//
//  Location.swift
//  ForeCast
//
//  Created by Srini Motheram on 3/20/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class Location: NSObject {
    
    var locationName    :String!
    var weatherSummary  :String!
    var icon            :String!
    
    var locationLat     :Double!
    var locationLon     :Double!
    
    var temp            :Double!
    var humidity        :Double!
    var windspeed       :Double!
    
    
    convenience init(name: String, summary: String, icon: String, lat: Double, lon: Double, temp: Double, humidity: Double, wind: Double) {
        self.init()
        self.locationName = name
        self.weatherSummary = summary
        self.icon = icon
        
        self.locationLat = lat
        self.locationLon = lon
        
        self.temp = temp
        self.humidity = humidity
        self.windspeed = wind
    }
    
}
