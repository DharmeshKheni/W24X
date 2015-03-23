//
//  Globals.swift
//  W24X
//
//  Created by Anil on 19/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit
import CoreLocation

extension NSObject {
    
    func callSelectorAsync(selector: Selector, object: AnyObject?, delay: NSTimeInterval) -> NSTimer {
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: selector, userInfo: object, repeats: false)
        return timer
    }
    
    func callSelector(selector: Selector, object: AnyObject?, delay: NSTimeInterval) {
        
        let delay = delay * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            NSThread.detachNewThreadSelector(selector, toTarget:self, withObject: object)
        })
    }
}

class Globals: NSObject, CLLocationManagerDelegate {
   
    var appDelegate = AppDelegate()
    var hasInternet = Bool()
    
    //webservice
    var webServiceLink = NSString()
    var webServiceVersion = NSString()
    
    //cover items
    var cover = UIView()
    var palette = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var statusLabel = UILabel()
    // databases
    var contentDB : COpaquePointer = nil
    var contentDBPath = NSString()
    
    //databases
    var userContentDB : COpaquePointer = nil
    var userContentDBPath = NSString()
    
    var locationManager = CLLocationManager()
    
    var preferredWeatherStyle = NSInteger()
    
    var deviceWidth = NSInteger()
    var deviceHeight = NSInteger()
    
    var internetReach : Reachability?
    var sharedInstance : Globals = Globals()
    
    var windArrowOn = Bool()
    var tfrOn = Bool()
    var airmetOn = Bool()
    var metarTimeOn = Bool()
    
    var usersStations = NSMutableArray()
    
    var minsOn = Bool()
    var timeOffset = NSInteger()
    var metarData = NSInteger()
    var dataLevel = NSInteger()
    
    var currentLocation = CLLocation()
    
    func initializeLocationManager(){
        
        if (!CLLocationManager.locationServicesEnabled()){
            
            var alert = UIAlertController(title: "No Location Services", message: "You must have your location services enabled for this app to work properly.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
        
//            presentViewController(alert, animated: true, completion: nil)
        }
        
        //check
        if (locationManager == ""){
            
            //set
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 100
        }
        
        //start
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as CLLocation
        NSLog("latitude %+.6f, longitude %+.6f, altitude %0.0f m\n", location.coordinate.latitude, location.coordinate.longitude, location.altitude)
        
        //set
//        currentLocation = location
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println("Location error")
    }
    
    //Database
    func checkDatabases(){
        
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
        if let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true){
            
            if paths.count > 0 {
                
                if let dirPath = paths[0] as? String {
                    
                    contentDBPath = dirPath.stringByAppendingPathComponent("W24xDB.sqlite")
                    userContentDBPath = dirPath.stringByAppendingPathComponent("W24xUserDB.sqlite")
                    let fileManager = NSFileManager.defaultManager()
                    
                    //Check if Path exists
                    if fileManager.fileExistsAtPath(contentDBPath){
                        
                        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
                        let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
                        if let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true){
                            
                            if paths.count > 0 {
                                
                                let storePath = dirPath.stringByAppendingPathComponent("W24xDB.sqlite")
                                
                                //vars
                                let fileManager = NSFileManager.defaultManager()
                                
                                //checks
                                if fileManager.fileExistsAtPath(storePath){
                                    
                                    let defaultStorePath = NSBundle.mainBundle().pathForResource("W24xDB", ofType: "sqlite")
                                    
                                    //check
                                    if (defaultStorePath != nil){
                                        
                                        fileManager.copyItemAtPath(defaultStorePath!, toPath: storePath, error: nil)
                                        println("copied database")
                                    }
                                }
                            }
                        }
                    }
                    // check if path exists
                    if fileManager.fileExistsAtPath(userContentDBPath){
                        
                        self.buildUserContentDatabase()
                    }
                }
            }
        }
    }
    
    func buildUserContentDatabase(){
        
        //vars
        let dbpath = userContentDBPath.UTF8String
        
        if sqlite3_open(dbpath, &userContentDB) == SQLITE_OK{
            
            //vars
            var errMsg : NSError?
            let sql_stmt = "CREATE TABLE IF NOT EXISTS UserStations (id INTEGER PRIMARY KEY AUTOINCREMENT, station_id INTEGER, user_order INTEGER)"
            
            //check
            if sqlite3_exec(userContentDB, sql_stmt, nil, nil, nil) == SQLITE_OK {
                
                let errmsg = String.fromCString(sqlite3_errmsg(userContentDB))
                println("error creating table: \(errmsg)")
            }
            
            //close
            sqlite3_close(userContentDB)
        }else{
            
            println("failed to create database")
        }
    }
    
    func getAllStations() -> NSMutableArray{
        //vars
        var contantArray = NSMutableArray()
        
        //vars
        let fileManager = NSFileManager.defaultManager()
        
        //check if path exists
        if fileManager.fileExistsAtPath(contentDBPath){
            
            var statement : COpaquePointer = nil
            let dbpath = contentDBPath.UTF8String
            
            // open database
            if sqlite3_open(dbpath, &contentDB) == SQLITE_OK{
                
                let querySQL : NSString = "SELECT * FROM Stations WHERE station_id != '' AND (country_abv = 'US' OR country_abv = 'CA') ORDER BY station_name"
                let query_stmt = querySQL.UTF8String
                
                //prepare
                sqlite3_prepare_v2(contentDB, query_stmt, -1, &statement, nil)
                
                // step throuhg result
                while(sqlite3_step(statement) == SQLITE_ROW){
                    
                    //vars
                    var tempObject = StationObject()
                    tempObject.serverId = sqlite3_column_int(statement, 0)
                    tempObject.stationId = NSString(bytes: sqlite3_column_text(statement, 1), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stationName = NSString(bytes: sqlite3_column_text(statement, 2), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.countryAbv = NSString(bytes: sqlite3_column_text(statement, 3), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stateAbv = NSString(bytes: sqlite3_column_text(statement, 4), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.latValue = NSString(bytes: sqlite3_column_text(statement, 5), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.longValue = NSString(bytes: sqlite3_column_text(statement, 6), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.elevation = sqlite3_column_int(statement, 7)
                    tempObject.reporting = NSString(bytes: sqlite3_column_text(statement, 8), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.city = NSString(bytes: sqlite3_column_text(statement, 9), length: Int(0), encoding: NSASCIIStringEncoding)!
                    
                    contantArray.addObject(tempObject)
                }
                
                // finish
                sqlite3_finalize(statement)
                sqlite3_close(contentDB)
            }else{
                
                //alert User
                println("error opening database")
            }
        }
        //return
        return contantArray
    }
    
    func getUserStations() -> NSMutableArray{
        
        // vars
        var contentArray = NSMutableArray()
        
        //vars
        let fileManager = NSFileManager.defaultManager()
        
        //check if path exists
        if fileManager.fileExistsAtPath(userContentDBPath){
            // vars
            var statement : COpaquePointer = nil
            let dbpath = userContentDBPath.UTF8String
            
            // open database
            if sqlite3_open(dbpath, &userContentDB) == SQLITE_OK{
                
                //query
               let querySQL = NSString(string: "SELECT * FROM UserStations ORDER BY user_order")
                let query_stmt = querySQL.UTF8String
                //prepare
                sqlite3_prepare_v2(userContentDB, query_stmt, -1, &statement, nil)
                
                // step thrugh result
                while(sqlite3_step(statement) == SQLITE_ROW){
                    
                    //vars
                    var serverId = sqlite3_column_int(statement, 1)
                    var orderNum = sqlite3_column_int(statement, 2)
                    
                    //vars
                    var sub_statement : COpaquePointer = nil
                    let contentdbpath = contentDBPath.UTF8String
                    
                    //open database
                    if sqlite3_open(contentdbpath, &contentDB) == SQLITE_OK{
                        
                        let contentQuerySQL = String(format: "SELECT * FROM Stations WHERE id = %lu", CUnsignedLong(serverId)) as NSString
                        let content_query_stmt = contentQuerySQL.UTF8String
                        
                        //prepare
                        sqlite3_prepare_v2(contentDB, content_query_stmt, -1, &sub_statement, nil)
                        
                        //step through result
                        while(sqlite3_step(sub_statement) == SQLITE_ROW){
                            // vars
                            var tempObject = StationObject()
                            tempObject.serverId = sqlite3_column_int(sub_statement, 0)
                            tempObject.stationId = NSString(bytes: sqlite3_column_text(sub_statement, 1), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.stationName = NSString(bytes: sqlite3_column_text(sub_statement, 2), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.countryAbv = NSString(bytes: sqlite3_column_text(sub_statement, 3), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.stateAbv = NSString(bytes: sqlite3_column_text(sub_statement, 4), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.latValue = NSString(bytes: sqlite3_column_text(sub_statement, 5), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                            tempObject.longValue = NSString(bytes: sqlite3_column_text(sub_statement, 6), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                            tempObject.elevation = sqlite3_column_int(sub_statement, 7)
                            tempObject.reporting = NSString(bytes: sqlite3_column_text(sub_statement, 8), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.city = NSString(bytes: sqlite3_column_text(sub_statement, 9), length: Int(0), encoding: NSASCIIStringEncoding)!
                            tempObject.order = orderNum
                             //add
                            contentArray.addObject(tempObject)
                
                        }
                        //finish
                        sqlite3_finalize(sub_statement)
                        sqlite3_close(contentDB)
                    }else{
                        
                        println("Error opening database")
                    }
                }
                //finish
                sqlite3_finalize(statement)
                sqlite3_close(userContentDB)
            }else{
                
                println("Error opening database")
            }
        }
        return contentArray
    }
    
    func addUserStation(thisStation : StationObject){
    
        // vars
        var fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(userContentDBPath){
            // var
            let dbpath = userContentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &userContentDB) == SQLITE_OK){
                // vars
                var insert_statement : COpaquePointer = nil
                let insertSQL = String(format: "INSERT INTO UserStations (station_id, user_order) VALUES (%lu, %lu)", CUnsignedLong(thisStation.serverId), CUnsignedLong(thisStation.order)) as NSString
                
                let insert_stmt = insertSQL.UTF8String
                //NSLog(@"insert sql -%@-", insertSQL);
                
                // prepare
                sqlite3_prepare_v2(userContentDB, insert_stmt, -1, &insert_statement, nil)
                
                // check if added
                if (sqlite3_step(insert_statement) == SQLITE_DONE){
                    //
                    //NSLog(@"insert finished in addUserStation");
                }
                else {
                    println("error writing database addUserStation")
                }
                
                // finalize and close
                sqlite3_finalize(insert_statement)
                sqlite3_close(userContentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }
    }
    
    func deleteUserStation(thisStation : StationObject){
        
        // vars
        var fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(userContentDBPath){
            // var
            let dbpath = userContentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &userContentDB) == SQLITE_OK){
                // vars
                var insert_statement : COpaquePointer = nil
                let insertSQL = String(format: "DELETE FROM UserStations WHERE station_id = %lu", CUnsignedLong(thisStation.serverId)) as NSString
                
                let insert_stmt = insertSQL.UTF8String
                //NSLog(@"insert sql -%@-", insertSQL);
                
                // prepare
                sqlite3_prepare_v2(userContentDB, insert_stmt, -1, &insert_statement, nil)
                
                // check if added
                if (sqlite3_step(insert_statement) == SQLITE_DONE){
                    //
                    //NSLog(@"insert finished in addUserStation");
                }
                else {
                    println("error writing database addUserStation")
                }
                
                // finalize and close
                sqlite3_finalize(insert_statement)
                sqlite3_close(userContentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }

    }
    
    func updateUserStation(thisStation : StationObject){
        
        // vars
        var fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(userContentDBPath){
            // var
            let dbpath = userContentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &userContentDB) == SQLITE_OK){
                // vars
                var insert_statement : COpaquePointer = nil
                let insertSQL = String(format: "UPDATE UserStations SET user_order = %lu WHERE station_id = %lu", CUnsignedLong(thisStation.order), CUnsignedLong(thisStation.serverId)) as NSString
                
                let insert_stmt = insertSQL.UTF8String
                //NSLog(@"insert sql -%@-", insertSQL);
                
                // prepare
                sqlite3_prepare_v2(userContentDB, insert_stmt, -1, &insert_statement, nil)
                
                // check if added
                if (sqlite3_step(insert_statement) == SQLITE_DONE){
                    //
                    //NSLog(@"insert finished in addUserStation");
                }
                else {
                    println("error writing database addUserStation")
                }
                
                // finalize and close
                sqlite3_finalize(insert_statement)
                sqlite3_close(userContentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }
    }
    
    func getStationsById(thisId : NSString) -> NSMutableArray{
        
        // vars
        var contentArray = NSMutableArray()
        
        // vars
        let fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(contentDBPath){
            // vars
            var statement : COpaquePointer = nil
            let dbpath = contentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &contentDB) == SQLITE_OK){
                // query
                let querySQL = String(format: "SELECT * FROM Stations WHERE station_id LIKE '%%%@%%' ORDER BY station_id", thisId) as NSString
                let query_stmt = querySQL.UTF8String
                //NSLog(@"query sql -%@-", querySQL);
                
                // prepare
                sqlite3_prepare_v2(contentDB, query_stmt, -1, &statement, nil);
                
                // step through results
                while (sqlite3_step(statement) == SQLITE_ROW){
                    // vars
                    var tempObject = StationObject()
                    tempObject.serverId = sqlite3_column_int(statement, 0)
                    tempObject.stationId = NSString(bytes: sqlite3_column_text(statement, 1), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stationName = NSString(bytes: sqlite3_column_text(statement, 2), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.countryAbv = NSString(bytes: sqlite3_column_text(statement, 3), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stateAbv = NSString(bytes: sqlite3_column_text(statement, 4), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.latValue = NSString(bytes: sqlite3_column_text(statement, 5), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.longValue = NSString(bytes: sqlite3_column_text(statement, 6), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.elevation = sqlite3_column_int(statement, 7)
                    tempObject.reporting = NSString(bytes: sqlite3_column_text(statement, 8), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.city = NSString(bytes: sqlite3_column_text(statement, 9), length: Int(0), encoding: NSASCIIStringEncoding)!
                    
                    //NSLog(@"state is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]);
                    //NSLog(@"id is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]);
                    
                    // add
                    contentArray.addObject(tempObject)
                }
                
                // finish
                sqlite3_finalize(statement)
                sqlite3_close(contentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }
        
        // return
        return contentArray;
    }
    
    func getStationsByName(thisName : NSString) -> NSMutableArray{
        
        // vars
        var contentArray = NSMutableArray()
        
        // vars
        let fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(contentDBPath){
            // vars
            var statement : COpaquePointer = nil
            let dbpath = contentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &contentDB) == SQLITE_OK){
                // query
                let querySQL = String(format: "SELECT * FROM Stations WHERE station_name LIKE '%%%@%%' ORDER BY station_name", thisName) as NSString
                let query_stmt = querySQL.UTF8String
                //NSLog(@"query sql -%@-", querySQL);
                
                // prepare
                sqlite3_prepare_v2(contentDB, query_stmt, -1, &statement, nil);
                
                // step through results
                while (sqlite3_step(statement) == SQLITE_ROW){
                    // vars
                    var tempObject = StationObject()
                    tempObject.serverId = sqlite3_column_int(statement, 0)
                    tempObject.stationId = NSString(bytes: sqlite3_column_text(statement, 1), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stationName = NSString(bytes: sqlite3_column_text(statement, 2), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.countryAbv = NSString(bytes: sqlite3_column_text(statement, 3), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stateAbv = NSString(bytes: sqlite3_column_text(statement, 4), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.latValue = NSString(bytes: sqlite3_column_text(statement, 5), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.longValue = NSString(bytes: sqlite3_column_text(statement, 6), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.elevation = sqlite3_column_int(statement, 7)
                    tempObject.reporting = NSString(bytes: sqlite3_column_text(statement, 8), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.city = NSString(bytes: sqlite3_column_text(statement, 9), length: Int(0), encoding: NSASCIIStringEncoding)!
                    
                    //NSLog(@"state is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]);
                    //NSLog(@"id is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]);
                    
                    // add
                    contentArray.addObject(tempObject)
                }
                
                // finish
                sqlite3_finalize(statement)
                sqlite3_close(contentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }
        
        // return
        return contentArray;
    }
    
    func getLocalStationWithLocation(thisLocation : CLLocation) -> NSMutableArray{
        
        // vars
        var contentArray = NSMutableArray()
        
        // vars
        let fileManager = NSFileManager.defaultManager()
        
        // check if path exists
        if fileManager.fileExistsAtPath(contentDBPath){
            // vars
            var statement : COpaquePointer = nil
            let dbpath = contentDBPath.UTF8String
            
            // open database
            if (sqlite3_open(dbpath, &contentDB) == SQLITE_OK){
                // query
//                let querySQL = NSString(string: "SELECT * FROM Stations WHERE station_id != '' AND (country_abv = 'US' OR country_abv = 'CA') AND reporting = 'X' ORDER BY ABS(%0.6f - lat) + ABS(%0.6f - long) ASC LIMIT 10")
                let querySQL = String(format: "SELECT * FROM Stations WHERE station_id != '' AND (country_abv = 'US' OR country_abv = 'CA') AND reporting = 'X' ORDER BY ABS(%0.6f - lat) + ABS(%0.6f - long) ASC LIMIT 10", thisLocation.coordinate.latitude, thisLocation.coordinate.longitude) as NSString
                let query_stmt = querySQL.UTF8String
                //NSLog(@"query sql -%@-", querySQL);
                
                // prepare
                sqlite3_prepare_v2(contentDB, query_stmt, -1, &statement, nil);
                
                // step through results
                while (sqlite3_step(statement) == SQLITE_ROW){
                    // vars
                    var tempObject = StationObject()
                    tempObject.serverId = sqlite3_column_int(statement, 0)
                    tempObject.stationId = NSString(bytes: sqlite3_column_text(statement, 1), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stationName = NSString(bytes: sqlite3_column_text(statement, 2), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.countryAbv = NSString(bytes: sqlite3_column_text(statement, 3), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.stateAbv = NSString(bytes: sqlite3_column_text(statement, 4), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.latValue = NSString(bytes: sqlite3_column_text(statement, 5), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.longValue = NSString(bytes: sqlite3_column_text(statement, 6), length: Int(0), encoding: NSASCIIStringEncoding)!.floatValue
                    tempObject.elevation = sqlite3_column_int(statement, 7)
                    tempObject.reporting = NSString(bytes: sqlite3_column_text(statement, 8), length: Int(0), encoding: NSASCIIStringEncoding)!
                    tempObject.city = NSString(bytes: sqlite3_column_text(statement, 9), length: Int(0), encoding: NSASCIIStringEncoding)!
                    
                    //NSLog(@"state is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]);
                    //NSLog(@"id is %@", [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)]);
                    
                    // add
                    contentArray.addObject(tempObject)
                }
                
                // finish
                sqlite3_finalize(statement)
                sqlite3_close(contentDB)
            }
            else{
                // alert user
                println("error opening database")
            }
        }
        
        // return
        return contentArray;
    }
    
    // pragma mark - Menu Functions
    
    func showViewToView(thisView: NSInteger, fromViewController thisViewController : UIViewController, withDelay thisDelay: NSTimeInterval){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var tempClass = UIViewController()
        
        // check
        if(thisView == 1){
            // check
            if(preferredWeatherStyle == 0){
                // check
                if ((appDelegate.window?.rootViewController?.isKindOfClass(WeatherMain)) != nil){
                    //change
                    tempClass = storyboard.instantiateViewControllerWithIdentifier("WeatherMain") as WeatherMain
                }
            }
            else {
                // check
                if ((appDelegate.window?.rootViewController?.isKindOfClass(WeatherList)) != nil){
                    // change
                    tempClass = storyboard.instantiateViewControllerWithIdentifier("WeatherList") as WeatherList
                }
            }
        }
        else if(thisView == 2){
                
                //check
                if ((appDelegate.window?.rootViewController?.isKindOfClass(TripNavigationController)) != nil){
                    //change
                    tempClass = storyboard.instantiateViewControllerWithIdentifier("TripNavigationController") as TripNavigationController
                }
            }
        else if(thisView == 3){
            
            //check
            if ((appDelegate.window?.rootViewController?.isKindOfClass(Mins)) != nil){
                //change
                tempClass = storyboard.instantiateViewControllerWithIdentifier("Mins") as Mins
            }
        }
        else if(thisView == 4){
            
            //check
            if ((appDelegate.window?.rootViewController?.isKindOfClass(UserStations)) != nil){
                //change
                tempClass = storyboard.instantiateViewControllerWithIdentifier("UserStations") as UserStations
            }
        }
        else if(thisView == 9){
            
            //check
            if ((appDelegate.window?.rootViewController?.isKindOfClass(Settings)) != nil){
                //change
                tempClass = storyboard.instantiateViewControllerWithIdentifier("Settings") as Settings
            }
            
        }
        //check
        if tempClass != ""{
            
            //set
            self.callSelector("setNextRootViewController", object: tempClass, delay: thisDelay)
        }
    }
    
    func setNextRootViewController(thisViewController : UIViewController){
        
        appDelegate.window?.rootViewController = thisViewController
    }
    
    //Misc Functions
    func getDevice() -> NSString{
        
        //vars
        var this_device : NSString = ""
        var size = size_t()
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](count: Int(size) + 1, repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        machine[Int(size)] = 0
        let machineString = String.fromCString(machine)! as NSString
        
        //check
        if machineString.isEqualToString("iPad1,1"){
            
            //set
            this_device = "iPad1"
        }
        else if machineString.isEqualToString("iPad2,1") || machineString.isEqualToString("iPad2,2") || machineString.isEqualToString("iPad2,2") || machineString.isEqualToString("iPad2,4"){
            
            //set
            this_device = "iPad2"
        }
        else if machineString.isEqualToString("iPad3,1") || machineString.isEqualToString("iPad3,2") || machineString.isEqualToString("iPad3,3"){
            
            //set
            this_device = "iPad3"
        }
        else if machineString.isEqualToString("iPad3,4") || machineString.isEqualToString("iPad3,5") || machineString.isEqualToString("iPad3,6"){
            
            //set
            this_device = "iPad4"
        }
        else if machineString.isEqualToString("iPad4,1") || machineString.isEqualToString("iPad4,2") {
            
            //set
            this_device = "iPadAir"
        }
        else if machineString.isEqualToString("iPad2,5") || machineString.isEqualToString("iPad2,6") || machineString.isEqualToString("iPad2,7"){
            
            //set
            this_device = "iPadMini"
        }
        else if machineString.isEqualToString("iPad4,4") || machineString.isEqualToString("iPad4,5") {
            
            //set
            this_device = "iPadMini2"
        }
        else if machineString.isEqualToString("iPhone1,1"){
            // set
            this_device = "iPhone2G"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPhone1,2"){
            // set
            this_device = "iPhone3G"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPhone2,1"){
            // set
            this_device = "iPhone3GS"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPhone3,1") || machineString.isEqualToString("iPhone3,2") || machineString.isEqualToString("iPhone3,3"){
            // set
            this_device = "iPhone4"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPhone4,1"){
            // set
            this_device = "iPhone4S"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPhone5,1") || machineString.isEqualToString("iPhone5,2"){
            // set
            this_device = "iPhone5"
            deviceWidth = 320
            deviceHeight = 568
        }
        else if machineString.isEqualToString("iPhone5,3") || machineString.isEqualToString("iPhone5,4"){
            // set
            this_device = "iPhone5C"
            deviceWidth = 320
            deviceHeight = 568
        }
        else if machineString.isEqualToString("iPhone6,1") || machineString.isEqualToString("iPhone6,2"){
            // set
            this_device = "iPhone5S"
            deviceWidth = 320
            deviceHeight = 568
        }
        else if machineString.isEqualToString("iPhone7,2"){
            // set
            this_device = "iPhone6"
            deviceWidth = 375
            deviceHeight = 667
        }
        else if machineString.isEqualToString("iPhone7,1"){
            // set
            this_device = "iPhone6+"
            deviceWidth = 414
            deviceHeight = 736
        }
        else if machineString.isEqualToString("iPod1,1"){
            // set
            this_device = "iPod1"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPod2,1"){
            // set
            this_device = "iPod2"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPod3,1"){
            // set
            this_device = "iPod3"
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPod4,1"){
            // set
            this_device = "iPod4" // retina
            deviceWidth = 320
            deviceHeight = 480
        }
        else if machineString.isEqualToString("iPod5,1"){
            // set
            this_device = "iPod5" // retina 568
            deviceWidth = 320
            deviceHeight = 568
        }
        else if machineString.isEqualToString("i386"){
            // set
            this_device = "Simulator"
            deviceWidth = 320
            deviceHeight = 568
        }
        else if machineString.isEqualToString("x86_64"){
            // set
            this_device = "iPhone Simulator"
            deviceWidth = 375
            deviceHeight = 667
        }
        else{
            // set
            this_device = "Unknown"
        }
        
        // dealloc
        println("this device is \(this_device)")
        return this_device;
    }
    
    func getColorWithName(thisColor : NSString) -> UIColor{
        
        var colorReturn = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1)
        // check
        if thisColor.isEqualToString("dark grey") || thisColor.isEqualToString("Dark Grey"){
            // set
            colorReturn = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("green") || thisColor.isEqualToString("Green"){
            // set
            colorReturn = UIColor(red: 42/255.0, green: 178/255.0, blue: 70/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("dark green")||thisColor.isEqualToString("Dark Green"){
            // set
            colorReturn = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 5)
        }
        else if thisColor.isEqualToString("light green") || thisColor.isEqualToString("Light Green"){
            // set
            colorReturn = UIColor(red: 152/255.0, green: 204/255.0, blue: 152/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("pink") ||  thisColor.isEqualToString("Pink"){
            // set
            colorReturn = UIColor(red: 255/255.0, green: 204/255.0, blue: 147/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("blue") || thisColor.isEqualToString("Blue"){
            // set
            colorReturn = UIColor(red: 27/255.0, green: 109/255.0, blue: 193/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("light blue") || thisColor.isEqualToString("Light Blue"){
            // set
            colorReturn = UIColor(red: 130/255.0, green: 210/255.0, blue: 250/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("purple") || thisColor.isEqualToString("Purple"){
            // set
            colorReturn = UIColor(red: 204/255.0, green: 192/255.0, blue: 197/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("scarlet") || thisColor.isEqualToString("Scarlet"){
            // set
            colorReturn = UIColor(red: 176/255.0, green: 1/255.0, blue: 1/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("red") || thisColor.isEqualToString("Red"){
            // set
        colorReturn = UIColor(red: 255/255.0, green: 15/255.0, blue: 15/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("dark red") || thisColor.isEqualToString("Dark Red"){
            // set
            colorReturn = UIColor(red: 140/255.0, green: 42/255.0, blue: 42/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("magenta") || thisColor.isEqualToString("Magenta"){
            // set
            colorReturn = UIColor(red: 255/255.0, green: 42/255.0, blue: 255/255.0, alpha: 1)
        }
        else if thisColor.isEqualToString("none") || thisColor.isEqualToString("None"){
            // set
            colorReturn = UIColor.clearColor()
        }
        
        // return
        return colorReturn;
    }
    
    func showCover(displayText : NSString, thisView : UIView){
        
        //vars
        var sizeOffset : NSInteger = 0
        
        //check
        if deviceHeight == 480{
            
            //set
            sizeOffset = -44
        }
        
        //set cover
        if cover == ""{
            
            cover = UIView(frame: CGRectMake(0, 0, 320, CGFloat(deviceHeight)))
            cover.backgroundColor = UIColor.blackColor()
            cover.alpha = 0.5
            
            //vars
            thisView.addSubview(cover)
        }
        
        //add palette
        if palette == ""{
            
            // create new
            palette = UIView(frame: CGRectMake(0, 0, 320, 568))
            palette.backgroundColor = UIColor.clearColor()
            
            // vars
            thisView.addSubview(palette)
            
            // image
            var bkgImage = UIImage(named: "CoverBkg.png")
            var bkgImageHolder = UIImageView(frame: CGRectMake(0, CGFloat(sizeOffset), 320, 568))
            bkgImageHolder.backgroundColor = UIColor.clearColor()
            bkgImageHolder.image = bkgImage
            palette.addSubview(bkgImageHolder)
            
        }
        
        // set activity indicator
        if activityIndicator == ""{
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.center = CGPointMake(160, 310 + CGFloat(sizeOffset))
            activityIndicator.color = UIColor.darkGrayColor()
            palette.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        }
        
        // add text
        if statusLabel == ""{
            
            statusLabel = UILabel(frame: CGRectMake(90, 250 + CGFloat(sizeOffset), 140, 36))
            statusLabel.backgroundColor = UIColor.clearColor()
            statusLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            statusLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            statusLabel.numberOfLines = 3
            statusLabel.textColor = UIColor.darkGrayColor()
            statusLabel.textAlignment = NSTextAlignment.Center
            statusLabel.text = displayText
            palette.addSubview(statusLabel)
        }
        else{
            
            // update text
            statusLabel.text = displayText
        }
    }
    
    func removeCover(){
        
        // remove cover
        if cover != ""{
            
            cover.removeFromSuperview()
//            cover = ""
        }
        // remove indicator
        if activityIndicator != ""{
            
            activityIndicator.removeFromSuperview()
//            activityIndicator = ""
        }
        // remove label
        if statusLabel != ""{
            
            statusLabel.removeFromSuperview()
//            statusLabel = ""
        }
        //remove palette
        if palette != ""{
            
            palette.removeFromSuperview()
//            palette = ""
        }
    }
    
    func startReachability(){
        
        // set up for notification
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged", name: ReachabilityChangedNotification, object: nil)
        
        // set internet reachability
        internetReach = Reachability.reachabilityForInternetConnection()
        internetReach?.startNotifier()
        self.updateInterfaceWithReachability(internetReach!)
    }
    
    func reachabilityChanged(note: NSNotification){
        
        var curReach : Reachability = note.object as Reachability
        assert(curReach.isKindOfClass(Reachability), "nil value")
        self.updateInterfaceWithReachability(curReach)
    }
    
    func updateInterfaceWithReachability(curReach : Reachability){
        
        var netStatus = curReach.currentReachabilityStatus
        
        //check if internet can be reach
        if curReach == internetReach{
            
            // check status
            switch netStatus{
                
            case .NotReachable:
                hasInternet = false
            case .ReachableViaWWAN:
                hasInternet = true
            case .ReachableViaWiFi:
                hasInternet = true
            }
        }
    }
}


















































