//
//  MenuView.swift
//  W24X
//
//  Created by Anil on 20/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit

protocol MenuViewDelegate {
    func menuBtnWasTouchedWithView(thisView : Int)
}

class MenuView: UIView {
    
    // delegates
    var appDelegate = AppDelegate()
    var myDelegate : MenuViewDelegate?
    
    // ui items
    var weatherBtn = UIButton()
    var tripBtn = UIButton()
    var stationsBtn = UIButton()
    var minsBtn = UIButton()
    var settingsBtn = UIButton()
    
    @IBAction func menuBtnTouched(sender: UIButton) {
        // vars
        var thisBtn = sender
        var btnTag = thisBtn.tag
        
        //callback
       myDelegate?.menuBtnWasTouchedWithView(btnTag)
    }
    
    func buildMenu(){
        // vars
        var curY : NSInteger = 64
        
        // add logo
        var mixterLogo = UIImage(named: "Logo.png")
        var logoImageView = UIImageView(frame: CGRectMake(95, 16, 60, 60))
        logoImageView.image = mixterLogo
        logoImageView.alpha = 1
        logoImageView.backgroundColor = UIColor.clearColor()
        self.addSubview(logoImageView)
        
        //divider
        var dividerImage = UIImage(named: "Divider.png")
        
        // weather btn
        var weatherImage = UIImage(named: "WeatherBtn.png")
        weatherBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        weatherBtn.frame = CGRectMake(0, CGFloat(curY), 250, 64)
        weatherBtn.setTitle("Weather", forState: UIControlState.Normal)
        weatherBtn.setImage(weatherImage, forState: UIControlState.Normal)
        weatherBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 198)
        weatherBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        weatherBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        weatherBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        weatherBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -120, 0, 0)
        weatherBtn.backgroundColor = UIColor.clearColor()
        weatherBtn.tag = 1
        weatherBtn.addTarget(self, action: "menuBtnTouched", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(weatherBtn)
        
        // increment
        curY += 64
        
        var dividerImage2 = UIImageView(frame: CGRectMake(70, CGFloat(curY), 250, 1))
        dividerImage2.image = dividerImage
        self.addSubview(dividerImage2)
        
        //increment
        curY += 0
        
        //trip btn
        var tripImage = UIImage(named: "TripBtn.png")
        tripBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        tripBtn.frame = CGRectMake(0, CGFloat(curY), 250, 64)
        tripBtn.setTitle("Trip", forState: UIControlState.Normal)
        tripBtn.setImage(weatherImage, forState: UIControlState.Normal)
        tripBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 200)
        tripBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        tripBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tripBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        tripBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -120, 0, 0)
        tripBtn.backgroundColor = UIColor.clearColor()
        tripBtn.tag = 2
        tripBtn.addTarget(self, action: "menuBtnTouched", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(tripBtn)
        
        // increment
        curY += 64
        
        var dividerImage3 = UIImageView(frame: CGRectMake(70, CGFloat(curY), 250, 1))
        dividerImage3.image = dividerImage
        self.addSubview(dividerImage3)
        
        // increment
        curY += 0
        
        //trip btn
        var stationsImage = UIImage(named: "StationsBtn.png")
        stationsBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        stationsBtn.frame = CGRectMake(0, CGFloat(curY), 250, 64)
        stationsBtn.setTitle("Stations", forState: UIControlState.Normal)
        stationsBtn.setImage(stationsImage, forState: UIControlState.Normal)
        stationsBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 200)
        stationsBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        stationsBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        stationsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        stationsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -120, 0, 0)
        stationsBtn.backgroundColor = UIColor.clearColor()
        stationsBtn.tag = 4
        stationsBtn.addTarget(self, action: "menuBtnTouched", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(stationsBtn)
        
        // increment
        curY += 64
        
        var dividerImage6 = UIImageView(frame: CGRectMake(70, CGFloat(curY), 250, 1))
        dividerImage6.image = dividerImage
        self.addSubview(dividerImage6)
        
        // increment
        curY += 0
        
        //mins btn
        var minsImage = UIImage(named: "MinsBtn.png")
        minsBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        minsBtn.frame = CGRectMake(0, CGFloat(curY), 250, 64)
        minsBtn.setTitle("Mins", forState: UIControlState.Normal)
        minsBtn.setImage(minsImage, forState: UIControlState.Normal)
        minsBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 200)
        minsBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        minsBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        minsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        minsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -120, 0, 0)
        minsBtn.backgroundColor = UIColor.clearColor()
        minsBtn.tag = 3
        minsBtn.addTarget(self, action: "menuBtnTouched", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(minsBtn)
        
        // increment
        curY += 64
        
        var dividerImage5 = UIImageView(frame: CGRectMake(70, CGFloat(curY), 250, 1))
        dividerImage5.image = dividerImage
        self.addSubview(dividerImage5)
        
        // increment
        curY += 0
        
        //settings btn
        var settingsImage = UIImage(named: "SettingsBtn.png")
        settingsBtn = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        settingsBtn.frame = CGRectMake(0, CGFloat(curY), 250, 64)
        settingsBtn.setTitle("Settings", forState: UIControlState.Normal)
        settingsBtn.setImage(settingsImage, forState: UIControlState.Normal)
        settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 200)
        settingsBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 24)
        settingsBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        settingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        settingsBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -120, 0, 0)
        settingsBtn.backgroundColor = UIColor.clearColor()
        settingsBtn.tag = 9
        settingsBtn.addTarget(self, action: "menuBtnTouched", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(settingsBtn)
        
        // increment
        curY += 64
        
        var dividerImage4 = UIImageView(frame: CGRectMake(70, CGFloat(curY), 250, 1))
        dividerImage4.image = dividerImage
        self.addSubview(dividerImage4)
        
        // increment
        curY += 0
        
    }
}