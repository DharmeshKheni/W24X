//
//  GraphicView.swift
//  W24X
//
//  Created by Anil on 21/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit
import Foundation

protocol GraphicViewDelegate {
    func metarTouchedWithMetar(thisMetar: MetarObject)
    func tafTouchedWithTAF(thisTAF: TAFObject)
    func metarDataToggleTouched()
}

class GraphicView: UIView {

    // delegates
    var appDelegate = AppDelegate()
    var myDelegate : GraphicViewDelegate?
    
    // vars
    var thisStation = StationObject()
    var graphicBackgroundColor = UIColor()
    var baseRadius = Float()
    var metarObjectBase = MetarObject()
    var tfrObjectBase = TFRObject()
    var tafObjectBase = TAFObject()
    var airmetObjectBase = AirmetObject()
    
    
    func metarSingleTap(gesture : UITapGestureRecognizer){
        // callback
        myDelegate?.metarDataToggleTouched()
    }
    
    func metarDoubleTap(gesture: UITapGestureRecognizer!){
        //callback
        myDelegate?.metarTouchedWithMetar(metarObjectBase)
    }
    
    func tafSingleTap(gesture: UITapGestureRecognizer!){
        //callback
        println("Single")
    }
    
    func tafDoubleTap(gesture: UITapGestureRecognizer!){
        //callback
        myDelegate?.tafTouchedWithTAF(tafObjectBase)
    }
    
    func updateView(){
        
        self.setNeedsDisplay()
    }
   
    override func drawRect(rect: CGRect){
        
        //Drawing Code
        println("drawing")
        
        //check
        if self.subviews.count > 0{
            //clear
            for tempView in self.subviews{
                
                //remove
                (tempView as UIView).removeFromSuperview()
            }
        }
        
        //vars
        var center = CGPointMake(frame.size.width / 2, frame.size.height / 2)
        var metarRadius = CGFloat(baseRadius)
        var tfrRadius = metarRadius + 8
        var tafRadius  = tfrRadius + 48
        var tafOuterPadding : CGFloat = 1
        
        var airmetIFRRadius = tafRadius + tafOuterPadding + 8
        var airmetIFROuterPadding : CGFloat = 1
        var airmetICERadius  = airmetIFRRadius + airmetIFROuterPadding + 8
        var airmetICEOuterPadding : CGFloat = 1
        var airmetTURBRadius = airmetICERadius + airmetICEOuterPadding + 8
        var airmetTURBOuterPadding : CGFloat = 1
        var airmetMTNRadius = airmetTURBRadius + airmetTURBOuterPadding + 8
        var airmetMTNOuterPadding : CGFloat = 1
        var airmetCONVRadius  = airmetMTNRadius + airmetMTNOuterPadding + 8
        
        // offset
        var nowDate = NSDate()
        
        //dout
        var timeZoneSeconds = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
        var utcDate : NSDate = nowDate.dateByAddingTimeInterval(timeZoneSeconds * -1)
        var metarDate : NSDate = metarObjectBase.dateUTC
        var distanceBetweenDates : NSTimeInterval = utcDate.timeIntervalSinceDate(metarDate)
        var minutesInAnHour : Double = 60
        var  secondsInAnHour : Double = 3600
        var  minutesBetweenDates = NSInteger(distanceBetweenDates / minutesInAnHour)
        var hoursBetweenDates = NSInteger(distanceBetweenDates / secondsInAnHour)
        var  timeOffset = NSInteger(hoursBetweenDates)
        
        //check
        if appDelegate.myGlobals.airmetOn {
            /* ==================== */
            // airmet conv bkg
            /* ====================*/

            var airmetCONVBkg = UIBezierPath(arcCenter: center, radius: airmetCONVRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetCONVBkg.fill()
            
            /* ==================== */
            // airmet conv
            /* ====================*/
            
            for convObject in airmetObjectBase.convSegments{
                // vars
                
                var convFill = appDelegate.myGlobals.getColorWithName((convObject as AirmetSegmentObject).color)
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (convObject as AirmetSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (convObject as AirmetSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    
                    //set
                    startTime = 0
                }
                
                //check
                if endTime < 0{
                    //set
                    endTime == 0
                }
                
                var startDegrees : CGFloat = Int(((startTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((endTime - 6) * 15)).degreesToRadian
                
                // conv segemnt
                var convSegment = UIBezierPath()
                convSegment.moveToPoint(center)
                convSegment.addArcWithCenter(center, radius: airmetCONVRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                convSegment.addLineToPoint(center)
                convFill.setFill()
                convSegment.fill()
            }
            
            /* ==================== */
            // airmet mtn spacer
            /* ====================*/
            
            var airmetMTNSpacer = UIBezierPath(arcCenter: center, radius: (airmetMTNRadius + airmetMTNOuterPadding), startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetMTNSpacer.fill()
            
            /* ==================== */
            // airmet mtn bkg
            /* ====================*/
            var airmetMTNBkg = UIBezierPath(arcCenter: center, radius: airmetMTNRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetMTNBkg.fill()
            
            /* ==================== */
            // airmet mtn
            /* ====================*/
            for mtnObject in airmetObjectBase.mtnSegments{
                
                //vars
                var mtnFill = appDelegate.myGlobals.getColorWithName((mtnObject as AirmetSegmentObject).color)
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (mtnObject as AirmetSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (mtnObject as AirmetSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    
                    //set
                    startTime = 0
                }
                
                //check
                if endTime < 0{
                    //set
                    endTime == 0
                }
                
                var startDegrees : CGFloat = Int(((startTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((endTime - 6) * 15)).degreesToRadian
                
                // mtn segemnt
                var mtnSegment = UIBezierPath()
                mtnSegment.moveToPoint(center)
                mtnSegment.addArcWithCenter(center, radius: airmetMTNRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                mtnSegment.addLineToPoint(center)
                mtnFill.setFill()
                mtnSegment.fill()
            }
            
            /* ==================== */
            // airmet turb spacer
            /* ====================*/
            var airmetTURBSpacer = UIBezierPath(arcCenter: center, radius: (airmetTURBRadius + airmetTURBOuterPadding), startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetTURBSpacer.fill()
            
            /* ==================== */
            // airmet turb bkg
            /* ====================*/
            var airmetTURBBkg = UIBezierPath(arcCenter: center, radius: airmetTURBRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetMTNBkg.fill()
            
            /* ==================== */
            // airmet turb
            /* ====================*/
            for turbObject in airmetObjectBase.turbSegments{
                
                //vars
                var turbFill = appDelegate.myGlobals.getColorWithName((turbObject as AirmetSegmentObject).color)
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (turbObject as AirmetSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (turbObject as AirmetSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    
                    //set
                    startTime = 0
                }
                
                //check
                if endTime < 0{
                    //set
                    endTime == 0
                }
                
                var startDegrees : CGFloat = Int(((startTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((endTime - 6) * 15)).degreesToRadian
                
                // mtn segemnt
                var turbSegment = UIBezierPath()
                turbSegment.moveToPoint(center)
                turbSegment.addArcWithCenter(center, radius: airmetTURBRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                turbSegment.addLineToPoint(center)
                turbFill.setFill()
                turbSegment.fill()
            }
            
            /* ==================== */
            // airmet ice spacer
            /* ====================*/
            var airmetICESpacer = UIBezierPath(arcCenter: center, radius: (airmetICERadius + airmetICEOuterPadding), startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetICESpacer.fill()
            
            /* ==================== */
            // airmet ice bkg
            /* ====================*/
            var airmetICEBkg = UIBezierPath(arcCenter: center, radius: airmetICERadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetICEBkg.fill()
            
            /* ==================== */
            // airmet ice
            /* ====================*/
            for iceObject in airmetObjectBase.iceSegments{
                
                //vars
                var iceFill = appDelegate.myGlobals.getColorWithName((iceObject as AirmetSegmentObject).color)
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (iceObject as AirmetSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (iceObject as AirmetSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    
                    //set
                    startTime = 0
                }
                
                //check
                if endTime < 0{
                    //set
                    endTime == 0
                }
                
                var startDegrees : CGFloat = Int(((startTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((endTime - 6) * 15)).degreesToRadian
                
                // mtn segemnt
                var iceSegment = UIBezierPath()
                iceSegment.moveToPoint(center)
                iceSegment.addArcWithCenter(center, radius: airmetICERadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                iceSegment.addLineToPoint(center)
                iceFill.setFill()
                iceSegment.fill()
            }
            
            /* ==================== */
            // airmet ifr spacer
            /* ====================*/
            var airmetIFRSpacer = UIBezierPath(arcCenter: center, radius: (airmetIFRRadius + airmetIFROuterPadding), startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetIFRSpacer.fill()
            
            /* ==================== */
            // airmet ifr bkg
            /* ====================*/
            var airmetIFRBkg = UIBezierPath(arcCenter: center, radius: airmetIFRRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            graphicBackgroundColor.setFill()
            airmetIFRBkg.fill()
            
            /* ==================== */
            // airmet ifr
            /* ====================*/
            for ifrObject in airmetObjectBase.ifrSegments{
                
                //vars
                var ifrFill = appDelegate.myGlobals.getColorWithName((ifrObject as AirmetSegmentObject).color)
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (ifrObject as AirmetSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (ifrObject as AirmetSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    
                    //set
                    startTime = 0
                }
                
                //check
                if endTime < 0{
                    //set
                    endTime == 0
                }
                
                var startDegrees : CGFloat = Int(((startTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((endTime - 6) * 15)).degreesToRadian
                
                // ifr segemnt
                var ifrSegment = UIBezierPath()
                ifrSegment.moveToPoint(center)
                ifrSegment.addArcWithCenter(center, radius: airmetIFRRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                ifrSegment.addLineToPoint(center)
                ifrFill.setFill()
                ifrSegment.fill()
            }
        }
        
        /* ==================== */
        // airmet spacer
        /* ====================*/
        var airmetSpacer = UIBezierPath(arcCenter: center, radius: (tafRadius + tafOuterPadding), startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
        graphicBackgroundColor.setFill()
        airmetSpacer.fill()
        
        //check
        if thisStation.reporting.isEqualToString("M"){
            
            /* ==================== */
            // taf background
            /* ====================*/
            var tafBkg = UIBezierPath(arcCenter: center, radius: tafRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            UIColor(red: 70/255.0, green: 70/255.0, blue: 70/255.0, alpha: 1).setFill()
            tafBkg.fill()
        }
        else{
            /* ==================== */
            // taf background
            /* ====================*/
            var tafBkg = UIBezierPath(arcCenter: center, radius: tafRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1).setFill()
            tafBkg.fill()
            
            /* ==================== */
            // taf segments
            /* ====================*/
            for tafSegmentObject in tafObjectBase.segments{
                
                //vars
                var tafFill = appDelegate.myGlobals.getColorWithName((tafSegmentObject as TAFSegmentObject).color)
                var willCreateSegment = true
                var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafStartTimeInterval = (tafSegmentObject as TAFSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                var tafEndTimeInterval = (tafSegmentObject as TAFSegmentObject).endDateUTC.timeIntervalSince1970 as NSTimeInterval
                var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(tafEndTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                var endTime : CGFloat = (CGFloat(endTimeBetweenDates/3600) - CGFloat(timeOffset))
                
                //check
                if startTime < 0{
                    //check
                    if endTime <= 0{
                        //set
                        willCreateSegment = false
                    }
                    else{
                        //set
                        startTime = 0
                    }
                    
                }
                
                //check
                if willCreateSegment{
                    //circle 2
                    var tafSegment = UIBezierPath()
                    tafSegment.moveToPoint(center)
                    var startDegrees : CGFloat = Int(((startTime - 6) * 15) + 1).degreesToRadian
                    var endDegrees : CGFloat = Int(((endTime - 6) * 15) - 1).degreesToRadian
                    tafSegment.addArcWithCenter(center, radius: tafRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                    tafSegment.addLineToPoint(center)
                    tafFill.setFill()
                    tafSegment.fill()
                    
                    //check
                    if tafSegmentObject.icons.count == 1{
                        
                    }
                    else if tafSegmentObject.icons.count == 2{
                        
                    }
                }
                
            }
            
            /* ==================== */
            // taf arrows
            /* ====================*/
            if appDelegate.myGlobals.dataLevel > 0{
                for tafSegmentObject in tafObjectBase.segments{
                    
                    //vars
                    var willCreateArrow = true
                    var metarTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970 as NSTimeInterval
                    var tafStartTimeInterval = (tafSegmentObject as TAFSegmentObject).startDateUTC.timeIntervalSince1970 as NSTimeInterval
                    var startTimeBetweenDates = (Int(tafStartTimeInterval) - Int(metarTimeInterval)) as NSInteger
                    var startTime : CGFloat = (CGFloat(startTimeBetweenDates/3600) - CGFloat(timeOffset))
                    var displayTime = String(format: "%0.0f", startTime) as NSString
                    var calendar = NSCalendar.currentCalendar()
                    let components = calendar.components(.CalendarUnitHour , fromDate: (tafSegmentObject as TAFSegmentObject).startDateUTC)
                    let hour = components.hour
                    
                    //check
                    if appDelegate.myGlobals.timeOffset == 0{
                        //set
                        displayTime = String(format: "%ld", CLong(hour)) as NSString
                    }
                    else if appDelegate.myGlobals.timeOffset == 2 {
                        //vars
                        var localHourDifference = ((Int(timeZoneSeconds) * -1) / Int(secondsInAnHour)) as NSInteger
                        var offsetHour = (hour - localHourDifference) as NSInteger
                        
                        //check
                        if offsetHour < 0{
                            
                            //set
                            offsetHour = offsetHour * -1
                        }
                        
                        //set
                        displayTime = String(format: "%ld", CLong(offsetHour)) as NSString
                    }
                    
                    //check
                    if startTime <= 0 {
                        
                        //set
                        willCreateArrow = false
                    }
                    
                    //check
                    if willCreateArrow {
                        
                        //vars
                        var thisWidth : Int32 = (Int32(tafRadius) * 2) - 58
                        
                        //create new
                        var arrowView = UIView(frame: CGRectMake(center.x - (CGFloat(thisWidth/2)), (center.y - (CGFloat(thisWidth/2))), CGFloat(thisWidth), CGFloat(thisWidth)))
                        arrowView.backgroundColor = UIColor.clearColor()
                        self.addSubview(arrowView)
                        
                        //arrow Image
                        var timeStartImage = UIImage(named: "TimeArrow.png")
                        var timeStartImageView = UIImageView(frame: CGRectMake(0, 0, CGFloat(thisWidth), CGFloat(thisWidth)))
                        timeStartImageView.image = timeStartImage
                        arrowView.addSubview(timeStartImageView)
                        
                        // label
                        var timeLabel = UILabel(frame: CGRectMake((CGFloat(thisWidth/2) - 14), 3, 28, 20))
                        timeLabel.backgroundColor = UIColor.clearColor()
                        timeLabel.text = displayTime
                        timeLabel.textColor = UIColor.clearColor()
                        timeLabel.textAlignment = .Center
                        timeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 9)
                        arrowView.addSubview(timeLabel)
                        
                        //rotate
                        arrowView.transform = CGAffineTransformMakeRotation(Int(CGFloat(startTime) * 15).degreesToRadian as CGFloat)
                        timeLabel.transform = CGAffineTransformMakeRotation(Int(CGFloat(startTime) * 15).degreesToRadian as CGFloat)
                    }
                }
            }
            
            /* ==================== */
            // taf rect
            /* ====================*/
            var tafStartRect = UIBezierPath(rect: CGRectMake((center.x - 2), (center.y - tafRadius), 4, (tafRadius - tfrRadius)))
            graphicBackgroundColor.setFill()
            tafStartRect.fill()
        }
        
        //check
        if appDelegate.myGlobals.dataLevel > 1{
            //check
            if let tempDate = thisStation.midnightUTC as NSDate?{
                
                /* ==================== */
                // sunset sunrise
                /* ====================*/
                var metarTimeInterval : NSTimeInterval = metarObjectBase.dateUTC.timeIntervalSince1970
                var midnightTimeInterval : NSTimeInterval = thisStation.midnightUTC.timeIntervalSince1970
                var sunsetTimeInterval : NSTimeInterval = thisStation.sunsetUTC.timeIntervalSince1970
                var sunriseTimeInterval : NSTimeInterval = thisStation.sunriseUTC.timeIntervalSince1970
                var timeZoneSeconds : NSTimeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
                
                var midnightTimeBetweenDates = (Int(midnightTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var startTimeBetweenDates = (Int(sunsetTimeInterval) - Int(metarTimeInterval)) as NSInteger
                var endTimeBetweenDates = (Int(sunriseTimeInterval) - Int(metarTimeInterval)) as NSInteger
                
                var midnightTime : CGFloat = (CGFloat(midnightTimeBetweenDates/3600) - CGFloat(timeZoneSeconds))
                var sunsetTime : CGFloat = round((CGFloat(startTimeBetweenDates) - CGFloat(timeZoneSeconds)/3600))
                var sunriseTime = round((CGFloat(endTimeBetweenDates) - CGFloat(timeZoneSeconds))/3600)
                
                var startDegrees : CGFloat = Int(((sunsetTime - 6) * 15)).degreesToRadian
                var endDegrees : CGFloat = Int(((sunriseTime - 6) * 15)).degreesToRadian
                
                var sunCircle = UIBezierPath(arcCenter: center, radius: airmetCONVRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
                UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.25).setFill()
                sunCircle.fill()
                
                
                /* ==================== */
                // midnight rect
                /* ====================*/
                var midnightBkgCircle = UIBezierPath()
                midnightBkgCircle.moveToPoint(center)
                var startDegrees1 : CGFloat = Int(((midnightTime - 6) * 15) - 2).degreesToRadian
                var endDegrees1 : CGFloat = Int(((midnightTime - 6) * 15) + 2).degreesToRadian
                midnightBkgCircle.addArcWithCenter(center, radius: airmetCONVRadius, startAngle: startDegrees1, endAngle: endDegrees1, clockwise: true)
                midnightBkgCircle.addLineToPoint(center)
                UIColor.blackColor().setFill()
                midnightBkgCircle.fill()
                
                var midnightCircle = UIBezierPath()
                midnightCircle.moveToPoint(center)
                var startDegrees2 : CGFloat = Int(((midnightTime - 6) * 15) - 1).degreesToRadian
                var endDegrees2 : CGFloat = Int(((midnightTime - 6) * 15) + 1).degreesToRadian
                midnightBkgCircle.addArcWithCenter(center, radius: airmetCONVRadius, startAngle: startDegrees2, endAngle: endDegrees2, clockwise: true)
                midnightCircle.addLineToPoint(center)
                UIColor.whiteColor().setFill()
                midnightCircle.fill()
            }
        }
        
        /* ==================== */
        // tfr background
        /* ====================*/
        var tfrBkg = UIBezierPath(arcCenter: center, radius: tfrRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
        UIColor(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1).setFill()
        tfrBkg.fill()
        
        /* ==================== */
        // tfr
        /* ====================*/
        // check
        if appDelegate.myGlobals.tfrOn {
            //vars
            var tfrFill = appDelegate.myGlobals.getColorWithName(tfrObjectBase.color)
            
            // circle 2
            var tfrCircle = UIBezierPath()
            tfrCircle.moveToPoint(center)
            var startDegrees : CGFloat = Int((((CGFloat(tfrObjectBase.timeStart) - CGFloat(timeOffset)) - 6) * 15)).degreesToRadian
            var endDegrees : CGFloat = Int((((CGFloat(tfrObjectBase.timeEnd) - CGFloat(timeOffset)) - 6) * 15)).degreesToRadian
            tfrCircle.addArcWithCenter(center, radius: tfrRadius, startAngle: startDegrees, endAngle: endDegrees, clockwise: true)
            tfrCircle.addLineToPoint(center)
            tfrFill.setFill()
            tfrCircle.fill()
        }
        
        /* ==================== */
        // metar
        /* ====================*/
        
        var metarFill : UIColor = appDelegate.myGlobals.getColorWithName(metarObjectBase.color)
        
        //circle 1
        var metarCircle = UIBezierPath(arcCenter: center, radius: metarRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
        metarFill.setFill()
        metarCircle.fill()
        
        /* ==================== */
        // time circle
        /* ==================== */
        // check
        if appDelegate.myGlobals.metarTimeOn {
            
            //vars
            var endAngle : CGFloat = 360
            
            //check
            if minutesBetweenDates < 60 {
                //set
                endAngle = (CGFloat(minutesBetweenDates) - 15) * 6
            }
            
            //vars
            var timeCircleFill : UIColor = appDelegate.myGlobals.getColorWithName("dark green")
            
            //time circle
            var timeCircle = UIBezierPath()
            timeCircle.moveToPoint(center)
            timeCircle.addArcWithCenter(center, radius: tfrRadius, startAngle: CGFloat(Int(((-6 * 15))).degreesToRadian), endAngle: endAngle , clockwise: true)
            timeCircle.addLineToPoint(center)
            timeCircleFill.setFill()
            timeCircle.fill()
            
            // metar
            var metarCover = UIBezierPath(arcCenter: center, radius: metarRadius, startAngle: 0.0, endAngle: 360.degreesToRadian, clockwise: true)
            metarFill.setFill()
            metarCover.fill()
        }
        
        //check
        if appDelegate.myGlobals.dataLevel > 0 {
            //check
            if appDelegate.myGlobals.metarData == 1{
                // wind speed label
                var wsLabelWidth : Int32 = 50
                var windSpeedLabel = UILabel(frame: CGRectMake((center.x - round(CGFloat(wsLabelWidth/2))), (center.y - round(CGFloat(wsLabelWidth/2))), 50, 50))
                windSpeedLabel.backgroundColor = UIColor.clearColor()
                windSpeedLabel.text = String(format: "%ld", CLong(metarObjectBase.windSpeed))
                windSpeedLabel.textColor = UIColor.whiteColor()
                windSpeedLabel.textAlignment = .Center
                windSpeedLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
                self.addSubview(windSpeedLabel)
                
                //check
                if appDelegate.myGlobals.windArrowOn {
                    //wind speed direction
                    var windDirectionImage = UIImage(named: "Arrow.png")
                    var windDirectionImageView = UIImageView(frame: CGRectMake((center.x - CGFloat(metarRadius)), (center.y - CGFloat(metarRadius)), CGFloat(metarRadius) * 2, CGFloat(metarRadius) * 2))
                    windDirectionImageView.image = windDirectionImage
                    windDirectionImageView.transform = CGAffineTransformMakeRotation(Int(metarObjectBase.windDirection).degreesToRadian);
                    self.addSubview(windDirectionImageView)
                }
            }
            else if appDelegate.myGlobals.metarData == 2{
                //bar label
                var  barLabelWidth : Int32 = 100
                var barLabelHeight : Int32 = 50
                var barLabel = UILabel(frame: CGRectMake((center.x - round(CGFloat(barLabelWidth/2))), (center.y - round(CGFloat(barLabelHeight/2))),CGFloat(barLabelWidth), CGFloat(barLabelHeight)))
                barLabel.backgroundColor = UIColor.clearColor()
                barLabel.text = String(format: "%00.02f", metarObjectBase.barometerPressure)
                barLabel.textColor = UIColor.whiteColor()
                barLabel.textAlignment = .Center
                barLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
                self.addSubview(barLabel)
            }
            else if appDelegate.myGlobals.metarData == 3{
                //bar label
                var tempLabelWidth : Int32 = 100
                var tempLabelHeight : Int32 = 50
                var tempLabel = UILabel(frame: CGRectMake((center.x - round(CGFloat(tempLabelWidth/2))), (center.y - round(CGFloat(tempLabelHeight/2))),CGFloat(tempLabelWidth), CGFloat(tempLabelHeight)))
                tempLabel.backgroundColor = UIColor.clearColor()
                tempLabel.text = String(format: "%0.1f°", metarObjectBase.temperature)
                tempLabel.textColor = UIColor.whiteColor()
                tempLabel.textAlignment = .Center
                tempLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
                self.addSubview(tempLabel)
            }
        }
        /* ==================== */
        // taf button
        /* ====================*/
        var tafButton = UIButton.buttonWithType(.Custom) as UIButton
        tafButton.frame = CGRectMake(0, 0, tafRadius * 2, tafRadius * 2)
        tafButton.center = center
        tafButton.backgroundColor = UIColor.clearColor()
        tafButton.layer.cornerRadius = tafRadius
        self.addSubview(tafButton)
        
        var tafSingleTap = UITapGestureRecognizer(target: self, action: "tafSingleTap")
        var tafDoubleTap = UITapGestureRecognizer(target: self, action: "tafDoubleTap")
        
        tafSingleTap.numberOfTapsRequired = 1
        tafDoubleTap.numberOfTapsRequired = 2
        
        tafSingleTap.requireGestureRecognizerToFail(tafDoubleTap)
        
        tafButton.addGestureRecognizer(tafSingleTap)
        tafButton.addGestureRecognizer(tafDoubleTap)
        
        /* ==================== */
        // metar button
        /* ====================*/
        var metarButton = UIButton.buttonWithType(.Custom) as UIButton
        metarButton.frame = CGRectMake(0, 0, metarRadius * 2, metarRadius * 2)
        metarButton.center = center
        metarButton.backgroundColor = UIColor.clearColor()
        metarButton.layer.cornerRadius = metarRadius
        self.addSubview(metarButton)
        
        var metarSingleTap = UITapGestureRecognizer(target: self, action: "metarSingleTap")
        var metarDoubleTap = UITapGestureRecognizer(target: self, action: "metarDoubleTap")
        
        metarSingleTap.numberOfTapsRequired = 1
        metarDoubleTap.numberOfTapsRequired = 2
        
        metarSingleTap.requireGestureRecognizerToFail(metarDoubleTap)
        
        metarButton.addGestureRecognizer(metarSingleTap)
        metarButton.addGestureRecognizer(metarDoubleTap)
    }
}