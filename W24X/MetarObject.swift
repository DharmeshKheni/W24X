//
//  MetarObject.swift
//  W24X
//
//  Created by Paxton Calvanese on 3/19/15.
//  Copyright (c) 2015 Edge of the Atlas. All rights reserved.
//

import Foundation


class MetarObject{
    
    var color = "dark grey"
    var rawData :String
    var windSpeed :Int
    var windDirection :Int
    var barometerPressure = 0.0
    var temperature :Float
    var statMessage :String
    var statCode : Int
    var dateUTC: NSDate
    
    
init(){

        // set vars
        color = "dark grey";
        rawData = "";
        windSpeed = 0;
        windDirection = 0;
        barometerPressure = 00.00;
        temperature = 0;
        statMessage = "";
        statCode = 0;
        dateUTC = NSDate()

}
}