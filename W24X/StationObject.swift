//  Station.swift
//  W24X
//
//  Created by Paxton Calvanese on 3/19/15.
//  Copyright (c) 2015 Edge of the Atlas. All rights reserved.
//

import Foundation

class StationObject{
    
    var serverId = Int32()
    var stateAbv = NSString()
    var stationId = NSString()
    var stationName = NSString()
    var countryAbv = NSString()
    var latValue = Float()
    var longValue = Float()
    var elevation = Int32()
    var reporting = NSString()
    var city = NSString()
    
    var midnightUTC = NSDate()
    var sunsetUTC = NSDate()
    var sunriseUTC = NSDate()
    var nextriseUTC = NSDate()
    var timeZoneSeconds = NSInteger()
    
    var order = Int32()

}