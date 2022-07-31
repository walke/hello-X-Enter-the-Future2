//
//  LevelController.swift
//  testar
//
//  Created by diego on 6/2/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import AVKit
import SceneKit
import ARKit

class LevelController
{
    // MARK: - Controller Setup
    fileprivate let locationManager = CLLocationManager()
    
    var delegate:ViewController?
    
    var view : UIView?
    
    func setupLevelController(view:UIView) {
        self.view=view
        
        
        //setupLevels()
    }
    
    var unlockRangeCount=0
    
    // MARK: - Level Vars
    var currentLevel = 0
    var currentPart = 0
    
    // MARK: - MAP vars
    let locationUpdateThreshold = 0.00005
    var targetDistanceThreshold = 0.00005
    var mapView: MKMapView?
    var activeMapLayer:MapLayer?
    var lastKnownLocation:CLLocation?
    
    //MARK: - VIDEO vars
    var activePlayerLayer:PlayerLayer?
    
    //MARK: - AR vars
    var arView:ARSCNView?
    var activeARLayer:ARLayer?
    var objects:[String:SCNScene]
    
    var activeHelpLayer:HelpLayer?
    
    var activeMenuLayer:MenuLayer?
    
    var activeActionLayer:ActionLayer?
    
    class geoLocation{
        var lat:Double
        var lon:Double
        init(lat:Double,lon:Double) {
            self.lat=lat
            self.lon=lon
        }
    }
    
    // MARK: - Levels list
    var havn_loc        = geoLocation(lat:69.6467770, lon:18.9597430)
    var radhuset_loc    = geoLocation(lat:69.6515110, lon:18.9553790)
    //pazzing 69.6814625,18.987302
    //kysten 69.637865,18.932193
    //havn 69.647424,18.959046
    //house 69.646194,18.939201
    //radhuset 69.651511, 18.955379
    //balsfjord 69.453830, 18.988221
    //boden:65.818022, 21.614700
    var levels:[[[PartLayerClass]]]
    var levelsDATA:[Any]
    
    func setup(){
        
    }
    
    init()
    {
        objects=[String:SCNScene]()
        let fileManager = FileManager.default
        let subdir = Bundle.main.resourceURL!.appendingPathComponent("art.scnassets/objects").path

        do {
            let modelPathDirectoryFiles = try fileManager.contentsOfDirectory(atPath: subdir)
            
            for file in modelPathDirectoryFiles{
                //let filename = file.split {$0 == "."}.map(String.init)
                objects[file]=SCNScene(named:"art.scnassets/objects/"+(file))!
                //print (filename[0])
            }
            //then do my thing with the array
        } catch {
            print("error getting list of files")
        }
        levelsDATA = []
        if let path = Bundle.main.path(forResource: "levels", ofType: "json", inDirectory: "leveldata"){
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                let dictionary = jsonResult as? [String: [Any]]
                
                
                levelsDATA = dictionary?["levels"] as? [Any] ?? []
                
             } catch {levelsDATA = []}
        }

        /*if let path = Bundle.main.path(forResource: "levels", ofType: "json", inDirectory: "data") {
            print("!!")
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print("!!!!!!!!!")
                    print(jsonResult)
                  /*if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
                            // do stuff
                  }*/
              } catch {
                   // handle error
                  print(error)
              }
        }*/
        
        print ("OBJS INIT")
        
        levels=[]
    }
    
    
    // MARK: - Action Areas CLASS
    class ActionArea
    {
        init(type:String,priority:Int,pointer:Any,action:String,active:Bool,data:Any=[])
        {
            self.type=type
            self.piority=priority
            self.pointer=pointer
            self.action=action
            self.active=active
            self.data=data
        }
        let id=UUID()
        var type:String?
        var piority:Int?
        var pointer:Any?
        var action:String?
        var active:Bool=true
        var data:Any?
    }
    
    var actionAreas:[ActionArea] = []
    
    //MARK: - SETUP Levels
    /*func setupLevels()
    {
        for level in levels
        {
            for part in level
            {
                for layer in part
                {
                    layer.setup(view:self.view!,levelController: self)
                }
            }
        }
        
        
    }*/
    
    //MARK: - ActionAreas Management
    func addActionArea(actionArea:ActionArea)
    {
        actionAreas.append(actionArea)
    }
    
    func removeActionArea(actionArea:ActionArea)
    {
        actionAreas.removeAll{$0.id==actionArea.id}
        
    }
    
    //MARK: - GAME methods
    func play()
    {
        print("play")
        assamblePart()
    }
    
    func touch(point:CGPoint)
    {
        for actionArea in actionAreas
        {
            //print(actionArea.active)
            if(actionArea.active)
            {
                
                var actionRect:CGRect
                switch(actionArea.type)
                {
                    case "layer":
                        actionRect=(actionArea.pointer as! CATextLayer).frame
                    case "layerimage":
                        actionRect=(actionArea.pointer as! CALayer).frame
                    default:
                        actionRect=CGRect(x: 0, y: 0, width: 0, height: 0)
                        
                }
                
                
                //print("\(actionRect.debugDescription)")
                //print("\(point.debugDescription)")
                if(actionRect.contains(point))
                {
                    DispatchQueue.main.async {
                        self.doAction(type:actionArea.type!,action:actionArea.action!,data: actionArea.data!)
                        print("action \(actionArea.action!)")
                    }
                    
                    
                    return
                }
            }
            
        }
        
        if activeARLayer != nil
        {
            activeARLayer!.touch(point:point)
        }
    }
    
    func pushLocation(location:CLLocation)
    {
        if(lastKnownLocation==nil)
        {
            lastKnownLocation=location
            if activeMapLayer != nil
            {
                activeMapLayer!.lastKnownLocation=lastKnownLocation
                activeMapLayer!.locationUpdated()
            }
            else
            {
                delegate!.currentPositionUpdater(state:false)
            }
        }
        else
        {
            let dlat=location.coordinate.latitude-lastKnownLocation!.coordinate.latitude
            let dlon=location.coordinate.longitude-lastKnownLocation!.coordinate.longitude
            let dloc=sqrt(dlat*dlat+dlon*dlon)
            
            if(dloc>locationUpdateThreshold)
            {
                lastKnownLocation=location
                if activeMapLayer != nil
                {
                    activeMapLayer!.lastKnownLocation=lastKnownLocation
                    activeMapLayer!.locationUpdated()
                }
                else
                {
                    delegate!.currentPositionUpdater(state:false)
                }
            }
        }
        
        
        
    }
    
    
    
    
    func markerScanned(anchor:ARImageAnchor)
    {
        if activeARLayer != nil
        {
            activeARLayer!.markerScanned(anchor:anchor)
        }
    }
    
    func planeDetected(anchor:ARPlaneAnchor)
    {
        if activeARLayer != nil
        {
            activeARLayer!.planeDetected(anchor:anchor)
        }
    }
    
    func doAction(type:String,action:String,data:Any)
    {
        
        switch type {
            case "layer":
                switch action
                {
                    case "nextPart":
                        nextPart()
                    case "skipvideo":
                        activePlayerLayer?.skipVideo()
                    case "website":
                        //print(NSURL(string: "http://hellox.me")! as URL)
                        UIApplication.shared.open(NSURL(string: "http://hellox.me/book")! as URL,options: [:],completionHandler: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10)
                        {exit(0)}
                        
                    default:
                        print("invalid action")
                }
            case "layerimage":
                switch action
                {
                    case "nextPart":
                        nextPart()
                    case "skipvideo":
                        activePlayerLayer?.skipVideo()
                    case "rewindvideo":
                        activePlayerLayer?.rewindVideo()
                    case "showcontrolls":
                        activePlayerLayer?.showControlls()
                    case "showhelp":
                        activeHelpLayer?.showHelp()
                    case "hidehelp":
                        activeHelpLayer?.hideHelp()
                    case "showmenu":
                        activeMenuLayer?.showMenu()
                    case "setlevel1":
                        setLevel(level: 0)
                    case "setlevel2":
                        setLevel(level: 1)
                    case "setlevel3":
                        setLevel(level: 2)
                    case "unlockrange":
                        if unlockRangeCount<3
                        {
                            unlockRangeCount += 1
                        }else{
                            activeMapLayer?.targetEntranceThreshold=10.0
                            print("range unlocked")
                            activeMapLayer?.locationUpdated()
                        }
                        
                    case "website":
                        //print(NSURL(string: "http://hellox.me")! as URL)
                        UIApplication.shared.open(NSURL(string: "http://hellox.me/book")! as URL,options: [:],completionHandler: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10)
                        {exit(0)}
                        
                    default:
                        print("invalid action")
            }
            case "AR":
                if activeARLayer != nil
                {
                    switch action {
                    case "addARActiveElement":
                        activeARLayer!.addActiveElement(element:data as! ARLayer.ARActiveElement)
                    case "addARParticleElement":
                        activeARLayer!.addParticleElement(element:data as! ARLayer.ARParticleElement)
                    case "addARForceElement":
                        activeARLayer!.addForceElement(element:data as! ARLayer.ARForceElement)
                    case "removeARActiveElements":
                        activeARLayer!.removeActiveElements(elements:data as! [String])
                    default:
                        print("invalid action")
                    }
                }
            default:
                if activeActionLayer != nil
                {
                    activeActionLayer?.triggerCheck(trigger: action)
                }
                print("invalid action type")
            }
        
            
        
    }
    
    //MARK: - Level Management Methods
    func nextLevel()
    {
        //TODO: make or remove
    }
    
    func setLevel(level:Int)
    {
        cleanUpLevel()
        currentPart=0
        currentLevel=level
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            self.play()
        }
       
    }
    
    func nextPart()
    {
        /*for actar in actionAreas
        {print(actar)}*/
        
        //print("NEXT \(currentPart)")
        cleanUpPart()
        
        //iterate part
        currentPart+=1
        
        //if last part go to next level
        if levels[currentLevel].count-1 < currentPart
        {
            currentPart=0
            currentLevel+=1
            if currentLevel == 1 {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "level2unlocked")
            }
            if currentLevel == 2 {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "level3unlocked")
            }
        }
        //print("termetest \(levels.count) \(currentLevel-1)")
        if levels.count <= currentLevel
        {
            exit(0)
        }
        
        //play part
        play()
    }
    
    func assamblePart()
    {
        let part = loadPart(cLevel:currentLevel,cPart:currentPart)
       //!!!to delete: let part=levels[currentLevel][currentPart]
        
        for layer in part.layers
        {
            
            layer.putUp()

        }
    }
    
    func loadPart(cLevel:Int,cPart:Int) -> PartClass
    {
        let part = PartClass()
        
        let levelData = levelsDATA[currentLevel] as? [Any]
        let partData = levelData![currentPart] as? [Any]
        
       // print(levelData)
       // print(partData)
        if (partData != nil)
        {
            for layerData in partData!
            {
                var outLayer:PartLayerClass
                let layerObj = layerData as? [String:Any]
                let type=layerObj?["type"] as? String
                let duration=layerObj?["duration"] as? Int
                let color=layerObj?["color"] as? [String:CGFloat]
                switch type
                {
                case "solid":
                    outLayer=SolidLayer(
                        duration:duration ?? 1,
                        color:CGColor(red: color!["red"] ?? 0, green: color!["green"] ?? 0, blue: color!["blue"] ?? 0, alpha: color!["alpha"] ?? 0))
                    outLayer.setup(view:self.view!,levelController: self)
                    part.layers.append(outLayer)
                default:
                    print("invalid layer type")
                }
                
                
            }
        }
        
        
        part.setup(levelController: self)
        
        return part
    }
    
    func cleanUpLevel()
    {
        for index in 0 ..< currentLevel
        {
            for part in levels[index]
            {
                //print("l:\(index) p\(part)")
                for layer in part
                {
                    layer.takeDown()
                }
            }
        }
    
        for index in 0 ... currentPart
        {
            for layer in levels[currentLevel][index]
            {
                layer.takeDown()

            }
        }
    }
    
    func cleanUpPart()
   {
        for index in 0 ..< currentLevel
        {
            for part in levels[index]
            {
                //print("l:\(index) p\(part)")
                for layer in part
                {
                    if layer.duration >= 0
                    {
                        layer.duration!-=1
                        
                        if layer.duration <= 0
                        {
                            layer.takeDown()
                        }
                    }
                    
                }
            }
        }
    
        for index in 0 ... currentPart
        {
            //print("l:\(currentLevel) p\(index)")
            for layer in levels[currentLevel][index]
            {
                if layer.duration >= 0
                {
                    layer.duration!-=1
                    
                    if layer.duration <= 0
                    {
                        layer.takeDown()
                    }
                }
            }
        }
    }
}
