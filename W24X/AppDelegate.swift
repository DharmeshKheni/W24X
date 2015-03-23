//
//  AppDelegate.swift
//  W24X
//
//  Created by Anil on 19/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myGlobals = Globals()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
        //init globals
//        myGlobals = Globals.sharedInstance
        
        //check for network connections
        self.myGlobals.startReachability()
        
        // check settings
        self.checkSettings()
        
        // check database
        self.myGlobals.checkDatabases()
        
        // dailbreak
        var isJailbroken = self.checkIfJailbroken()
        
        // check
        if isJailbroken{
            
            var alert = UIAlertController(title: "Illegal Device!!!!!!", message: "You are using an illegal device. Our company does not support the use of illegal devices.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
        }
        return true
    }

    func checkSettings() -> Bool{
        // vars
        var defaults = NSUserDefaults.standardUserDefaults()
        
        // set version
        var version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as NSString
        var build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as NSString
        var fullVersion = String(format: "%@.%@", version, build) as NSString
        defaults.setObject(fullVersion, forKey: "version_preference")
        
        //set
        if (defaults.objectForKey("wind_arrow_on") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("wind_arrow_on") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(bool: true) , forKey: "wind_arrow_on")
        }
        
        //set
        if (defaults.objectForKey("tfr_on") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("tfr_on") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(bool: true) , forKey: "tfr_on")
        }
        
        //set
        if (defaults.objectForKey("airmet_on") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("airmet_on") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(bool: true) , forKey: "airmet_on")
        }
        
        //set
        if (defaults.objectForKey("metar_time_on") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("metar_time_on") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(bool: true) , forKey: "metar_time_on")
        }
        
        //set
        if (defaults.objectForKey("mins_on") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("mins_on") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(bool: true) , forKey: "mins_on")
        }
        
        //set
        if (defaults.objectForKey("time_offset") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("time_offset") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(integer: 1) , forKey: "time_offset")
        }
        
        //set
        if (defaults.objectForKey("metar_data") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("metar_data") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(integer: 1) , forKey: "metar_data")
        }
        
        //set
        if (defaults.objectForKey("data_level") != nil){
            // set
            self.myGlobals.windArrowOn = defaults.objectForKey("data_level") as Bool
        }
        else{
            //set
            defaults.setObject(NSNumber(integer: 2) , forKey: "data_level")
        }
        // save
        defaults.synchronize()
        
        //return
        return true
    }
    
    func checkIfJailbroken() -> Bool{
        
        // vars
        var boolReturn = false
        
        // check for cydia
        var url = NSURL(string: "cydia://package/com.example.package")
        if UIApplication.sharedApplication().canOpenURL(url!){
            // set
            boolReturn = true
        }
        
        // check for access outside sandbox
        if NSFileManager.defaultManager().fileExistsAtPath("/bin/bash"){
            // set
            //boolReturn = true
        }
        
        return boolReturn
    }
    
    func alertView(alertView : UIAlertView, didDismissWithButtonIndex buttonIndex : NSInteger){
        // exit
        exit(0)
    }
    
    func application(application : UIApplication, openURL url: NSURL, sourceApplication1 sourceApplication : NSString, annotation1 annotation: AnyObject) -> Bool{
        
        //[FBSession.activeSession handleOpenURL:url];
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

