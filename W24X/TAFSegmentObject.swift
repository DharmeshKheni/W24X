//
//  TAFSegmentObject.swift
//  W24X
//
//  Created by Paxton Calvanese on 3/19/15.
//  Copyright (c) 2015 Edge of the Atlas. All rights reserved.
//

import Foundation


class TAFSegmentObject{
    var color = "dark grey";
    var startDateUTC = NSDate()
    var endDateUTC = NSDate()
    var icons = NSMutableArray()
    
    var idx = 0;
    var ceiling = 0;
    var gu = 0;
    var layers = NSMutableArray()
    var type = "";
    var visibility = 0;
    var windDirection = 0;
    var windSpeed = 0;

}

