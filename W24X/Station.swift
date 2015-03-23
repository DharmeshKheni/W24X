//  Station.swift
//  W24X
//
//  Created by Paxton Calvanese on 3/19/15.
//  Copyright (c) 2015 Edge of the Atlas. All rights reserved.
//

import Foundation


class Station{

    var serverId : NSUInteger
    var  stateAbv : String
    var  stationId :Int
    var  stationName: String
    var  countryAbv: String
    var  latValue: Float
    var  longValue: float
    var  elevation: Int
    var  reporting: String
    var   city : String

    var midnightUTC;
    var sunsetUTC;
    var  sunriseUTC:NSDate
    var  nextriseUTC: NSDate
    var timeZoneSeconds : Int

    var order: Int

     init(){

        serverId = 0
        stateAbv = "";
        stationId = "";
        stationName = "";
        countryAbv = "";
        latValue = 0.0
        longValue = 0.0
        elevation = 0;
        reporting = "";
        city = "";
        midnightUTC = nil;
        sunsetUTC = nil;
        sunriseUTC = nil;
        nextriseUTC = nil;
        timeZoneSeconds = 0;

}

}