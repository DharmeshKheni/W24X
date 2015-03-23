//
//  WeatherMain.swift
//  W24X
//
//  Created by Anil on 19/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit

extension UIView {
    var subViews: [UIView] {
        return subviews as [UIView]
    }
}

class WeatherMain: UIViewController, UIScrollViewDelegate, MenuViewDelegate, GraphicViewDelegate {

    var appDelegate = AppDelegate()
    
    // ui iteams
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var hideMenuBtn: UIButton!
    @IBOutlet weak var noContentView: UIView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainPageView: UIPageControl!
    
    @IBOutlet weak var rawViewHolder: UIView!
    @IBOutlet weak var rawView: UIView!
    @IBOutlet weak var rawTitle: UILabel!
    @IBOutlet weak var rawText: UITextView!
    
    @IBOutlet weak var minsBtn: UIButton!
    @IBOutlet weak var offsetBtn: UIButton!
    
    @IBOutlet weak var centerRawViewConstraint: NSLayoutConstraint!
    
    // vars
    var menuOut = Bool()
    var rawOut = Bool()
    var startingRawViewConstraintConstant = CGFloat()
    var currentPage = Int32()
    
    //sub class
    var menuViewClass = MenuView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set app delegate
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        //init vars
        menuOut = false
        rawOut = false
        currentPage = 1
        
        // init ui items
        hideMenuBtn.hidden = true
        noContentView.hidden = true
        rawViewHolder.hidden = true
        
        // set
        appDelegate.myGlobals.usersStations = appDelegate.myGlobals.getUserStations()
        
        var longPress = UILongPressGestureRecognizer(target: self, action: "minsLongHold")
        minsBtn.addGestureRecognizer(longPress)
        
        // set
        self.setUIItems()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //check
        if menuViewClass == ""{
            
            //set
            menuViewClass = menuView as MenuView
            menuViewClass.myDelegate = self
        }
    }
    
    @IBAction func menuTouched(sender : AnyObject){
        //check
        if menuOut{
            
            //hide menu
            self.hideMainMenu()
        }
        else{
            //show menu
            self.showMainMenu()
        }
        
    }
    
    @IBAction func addStationTouched(sender : AnyObject){
        
        //show
        appDelegate.myGlobals.showViewToView(4, fromViewController: self, withDelay: 0.3)
    }
    
    @IBAction func listTouched(sender : AnyObject){
        //set
        appDelegate.myGlobals.preferredWeatherStyle = 1
        
        //change
        appDelegate.myGlobals.showViewToView(1, fromViewController: self, withDelay: 0)
        
    }
    
    @IBAction func changePage(sender : AnyObject){
        
        //vars
        var frame = CGRect()
        
        //set
        frame.origin.x = mainScrollView.frame.size.width * CGFloat(mainPageView.currentPage)
        frame.origin.y = 0
        frame.size = mainScrollView.frame.size
        
        //scroll
        mainScrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func rawCloseTouched(sender : AnyObject){
        
        //check
        if rawOut{
            
            //hide
            self.hideRawView()
        }
    }
    
    @IBAction func offsetTouched(sender : AnyObject){
        
        //increment
        var timeOffset = appDelegate.myGlobals.timeOffset
        timeOffset++
        
        //check
        if timeOffset >= 3{
            //set
            timeOffset = 0
        }
        
        //set
        appDelegate.myGlobals.timeOffset = timeOffset
        
        //save
        self.saveSettings()
        
        //refresh
        self.refreshView()
        
        //check
        if appDelegate.myGlobals.timeOffset == 0{
            //set
            offsetBtn.setTitle("Zulu", forState: UIControlState.Normal)
        }
        else if appDelegate.myGlobals.timeOffset == 1{
            //set
            offsetBtn.setTitle("Offset", forState: UIControlState.Normal)
        }
        else{
            //set
            offsetBtn.setTitle("Local", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func minsTouched(sender : AnyObject){
        
        //check
        if appDelegate.myGlobals.minsOn{
            
            appDelegate.myGlobals.minsOn = false
            
            //set
            minsBtn.selected = false
        }
        else{
            //toggle
            appDelegate.myGlobals.minsOn = true
            
            //set
            minsBtn.selected = true
        }
        //save
        self.saveSettings()
    }
    
    func minsLongHold(gesture : UILongPressGestureRecognizer){
        
        //check
        if gesture.state == UIGestureRecognizerState.Began{
            println("Long Press began")
        }
        else if gesture.state == UIGestureRecognizerState.Ended{
            println("Long press ended")
        }
    }
    
    @IBAction func dataTouched(sender : AnyObject){
        
        // increment
        var dataLevel = appDelegate.myGlobals.dataLevel
        dataLevel++
        
        //check
        if dataLevel >= 3{
            //set
            dataLevel = 0
        }
        
        //set
        appDelegate.myGlobals.dataLevel = dataLevel
        
        //save
        self.saveSettings()
        
        //refresh
        self.refreshView()
    }
    
    
    func setUIItems(){
        
        //clear
        for tempView in mainScrollView.subviews{
            //remove
            (tempView as UIView).removeFromSuperview()
        }
        
        //check
        if appDelegate.myGlobals.usersStations.count == 0{
            //show
            noContentView.hidden = false
        }
        else{
            //hide
            noContentView.hidden = true
            
            //build
            self.buildPageView()
        }
        
        //round
        rawView.layer.cornerRadius = 20
        
        //check
        if appDelegate.myGlobals.minsOn{
            //set
            minsBtn.selected = true
        }
        else{
            //set
            minsBtn.selected = false
        }
        
        //check
        if appDelegate.myGlobals.timeOffset == 0 {
            
            //set
            offsetBtn.setTitle("Zulu", forState: .Normal)
        }
        else if appDelegate.myGlobals.timeOffset == 1 {
            
            //set
            offsetBtn.setTitle("Offset", forState: .Normal)
        }
        else{
            
            //set
            offsetBtn.setTitle("Local", forState: .Normal)
        }
    }
    
    func buildPageView(){
     
        var curWidth = 320
        var curX = 0
        var curItem = 0
        
        //create a blank station
        var localObject = StationObject()
        appDelegate.myGlobals.usersStations.insertObject(localObject, atIndex: 0)
        
        for tempObject in appDelegate.myGlobals.usersStations {
            
            //vars
            var thisIndex = appDelegate.myGlobals.usersStations.indexOfObject(tempObject)
            var tempView = UIView(frame: CGRectMake(CGFloat(curX), 0, CGFloat(curWidth), 400))
            tempView.backgroundColor = UIColor.clearColor()
            tempView.tag = thisIndex + 100
            
            //check
            if thisIndex > 0{
                //add label
                var idLabel = UILabel(frame: CGRectMake(0, 20, CGFloat(curWidth), 30))
                idLabel.backgroundColor = UIColor.clearColor()
                idLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
                idLabel.textColor = UIColor(red: 0/255.0, green:0/255.0, blue:0/255.0, alpha:1)
                idLabel.text = (tempObject as StationObject).stationId
                idLabel.textAlignment = .Center
                
                //add
                tempView.addSubview(idLabel)
                
                //add label
                var nameLabel = UILabel(frame: CGRectMake(0, 44, CGFloat(curWidth), 30))
                nameLabel.backgroundColor = UIColor.clearColor()
                nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
                nameLabel.textColor = UIColor(red: 0/255.0, green:0/255.0, blue:0/255.0, alpha:1)
                nameLabel.text = (tempObject as StationObject).stationName
                nameLabel.textAlignment = .Center
                
                //add
                tempView.addSubview(nameLabel)
                
                //vars
                var graphicWidth = 320
                var startX = (curWidth - graphicWidth) / 2
                var graphicView = GraphicView()
                graphicView.myDelegate = self
                graphicView.frame = CGRectMake(CGFloat(startX), 80, CGFloat(graphicWidth), CGFloat(graphicWidth))
                graphicView.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
                graphicView.graphicBackgroundColor = graphicView.backgroundColor!
                
                //add
                mainScrollView.addSubview(graphicView)
                
                //increment
                curX += curWidth
                curItem++
            }
            
            //set
            var thisSize = CGSizeMake(CGFloat(curX), 400)
            mainScrollView.contentSize = thisSize
            mainScrollView.contentOffset = CGPointMake((CGFloat(currentPage) * CGFloat(curWidth)), 0)
            
            //set
            mainPageView.numberOfPages = appDelegate.myGlobals.usersStations.count
            
            //set
            mainPageView.currentPage = Int(currentPage)
        }
    }
    
    func getClosestStation(){
        
        //check
        if let tempLocation = appDelegate.myGlobals.currentLocation as CLLocation?{
            // vars
            var possibleStations = appDelegate.myGlobals.getLocalStationWithLocation(appDelegate.myGlobals.currentLocation) as NSMutableArray
            var closestDistance : CGFloat = 1000000
            var closestStation = StationObject()
            
            //cycle
            for tempStation in possibleStations{
                //vars
                
                var lat = Double((tempStation as StationObject).latValue)
                var long = Double((tempStation as StationObject).longValue)
                
                var stationLocation = CLLocation(latitude: lat, longitude: long)
                var thisDistance = CGFloat(appDelegate.myGlobals.currentLocation.distanceFromLocation(stationLocation))
                
                //check
                if CGFloat(thisDistance) < closestDistance {
                    //set
                    closestDistance = thisDistance
                    closestStation = tempStation as StationObject
                }
            }
            
            //check
            if let tempvalue = closestStation as StationObject?{
                
                //update
                self.updateClosestStationWithStation(closestStation)
            }
        }
    }
    
    func updateClosestStationWithStation(thisStation : StationObject){
        
        //vars
        var localView : UIView = mainScrollView.viewWithTag(100)!
        var curWidth : UInt32 = 320
        
        //clear
        for tempView in localView.subviews {
            //remove
            (tempView as UIView).removeFromSuperview()
        }
        
        //add label
        var idLabel = UILabel(frame: CGRectMake(0, 20, CGFloat(curWidth), 30))
        idLabel.backgroundColor = UIColor.clearColor()
        idLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        idLabel.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        idLabel.text = thisStation.stationId
        idLabel.textAlignment = .Center
        
        //add
        localView.addSubview(idLabel)
        
        //add label
        var nameLabel = UILabel(frame: CGRectMake(0, 44, CGFloat(curWidth), 30))
        nameLabel.backgroundColor = UIColor.clearColor()
        nameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        nameLabel.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
        nameLabel.text = thisStation.stationName
        nameLabel.textAlignment = .Center
        
        //add
        localView.addSubview(nameLabel)
        
        //vars
        var graphicWidth : Int32 = 320
        var startX : Int32 = Int32(CGFloat(curWidth) - CGFloat(graphicWidth))/2
        var graphicView = GraphicView()
        graphicView.myDelegate = self
        graphicView.frame = CGRectMake(CGFloat(startX), 80, CGFloat(graphicWidth), CGFloat(graphicWidth))
        graphicView.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        graphicView.graphicBackgroundColor = graphicView.backgroundColor!
        
        //add
        localView.addSubview(graphicView)
        
        //set data
        self.getStationDataWithStation(thisStation, withGraphicView: graphicView)
    }
    
    func saveSettings(){
        
        //vars
        var defaults = NSUserDefaults.standardUserDefaults()
        
        //set
        defaults.setObject(NSNumber(bool: appDelegate.myGlobals.minsOn), forKey: "mins_on")
        defaults.setObject(NSNumber(integer: appDelegate.myGlobals.timeOffset), forKey: "time_offset")
        defaults.setObject(NSNumber(integer: appDelegate.myGlobals.metarData), forKey: "metar_data")
        defaults.setObject(NSNumber(integer: appDelegate.myGlobals.dataLevel), forKey: "data_level")
        
        //save
        defaults.synchronize()
    
    }
    
    func refreshView(){
        //clear
        for subView in mainScrollView.subViews{
            //remove
            subView.removeFromSuperview()
        }
        
        //check
        if appDelegate.myGlobals.usersStations.count > 0{
            //remove
            appDelegate.myGlobals.usersStations.removeObjectAtIndex(0)
        }
        
        //set
        mainPageView.numberOfPages = 0
        
        //set
        mainPageView.currentPage = 0
        
        //rebuild
        self.buildPageView()
        
        //check
        if currentPage == 0{
            //get closest station
            self.getClosestStation()
        }
    }
    
    func menuBtnWasTouchedWithView(thisView : Int){
        
        //hide
        self.hideMainMenu()
        
        //show
        appDelegate.myGlobals.showViewToView(thisView, fromViewController: self, withDelay: 0.3)
        
    }
    
    func metarTouchedWithMetar(thisMetar : MetarObject){
        
        //set
        rawTitle.text = "Metar"
        thisMetar.rawData = thisMetar.rawData.stringByReplacingOccurrencesOfString(":", withString: "\n")
        rawText.text = thisMetar.rawData
        
        //check
        if rawOut{
            //show
            self.showRawView()
        }
    }
    
    func tafTouchedWithTAF(){
        //set
        rawTitle.text = "TAF"
        
    }
    func getStationDataWithStation(thisStation : StationObject, withGraphicView thisGraphicView : GraphicView){
        
        
    }
    func showMainMenu(){

    }
    func hideMainMenu(){
        
    }
    func hideRawView(){
        
    }
    
    func showRawView(){
        
        
    }
    
    
}











































