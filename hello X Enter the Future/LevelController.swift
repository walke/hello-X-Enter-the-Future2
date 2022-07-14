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
        
        
        setupLevels()
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
    
    func setup(){
        levels =
        [
            [//MARK: LEVEL1 dead tree
                [//intro
                    SolidLayer(
                        duration:5,
                        color:CGColor(red: 1.0, green: 0.97299844030000004, blue: 0.1611703038, alpha: 1.0)),
                    ImageLayer(duration: 1, image: "art.scnassets/images/yellowbk.png", frame: CGRect(x: 0, y: 0, width: 100, height: 100), keepAspect: "width", align: "middle"),
                    TextLayer(
                        duration:1,
                        text:"hello X:",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:10, width: 100, height: 20),fontSize: 40),
                    TextLayer(
                        duration:1,
                        text:"Enter the Future",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:18, width: 100, height: 30),fontSize: 30),
                    ChoiceLayer(
                        duration:1,
                        color:CGColor(red: 1.0, green: 0.97299844030000004, blue: 0.1611703038, alpha: 1.0),
                        bgcolor:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        position:CGPoint(x:0,y:-500),
                        buttons:
                        [
                            ChoiceLayer.Button(text:"START",action:"nextPart")
                        ]),
                    MenuLayer(duration: 1, color: "black")
                ],
                /*[//find entrance
                    MapLayer(
                        duration:1,
                        targetLocation:CLLocation(latitude: 69.637865, longitude: 18.932193),
                        targetAction:"nextPart",
                        targetTitle:"entrance"
                    ),
                    TextLayer(
                        duration:1,
                        text:"approach the entrance1",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                ],
                [//find entrance
                    MapLayer(
                        duration:1,
                        targetLocation:CLLocation(latitude: 69.637865, longitude: 18.932193),
                        targetAction:"nextPart",
                        targetTitle:"entrance"
                    ),
                    TextLayer(
                        duration:1,
                        text:"approach the entrance2",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                ],*/
                [//find entrance
                    MapLayer(
                        duration:1,
                        targetLocation:CLLocation(latitude: havn_loc.lat, longitude: havn_loc.lon),
                        targetAction:"nextPart",
                        targetTitle:"Havneterminalen"
                    ),
                    TextLayer(
                        duration:1,
                        text:"Gå til Havneterminalen",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:10, width: 100, height: 20),
                        fontSize: 26),
                    TextLayer(
                        duration:1,
                        text:"Se etter ‘soppsirkelen’ på et stort vindu.",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:80, width: 100, height: 20),
                        fontSize: 26),
                    MenuLayer(duration: 1, color: "white")
                ],
                [//play video
                    PlayerLayer(
                        duration:1,
                        /*local:false,
                        path:"http://ice-9.no/tests/hellox_vid_1.mp4",*/
                        local: true,
                        path:"scene1film1",
                        endText:"",
                        endAction:"nextPart")
                ],
                [//show scene
                    ARLayer(
                        duration:2,
                        originType:"ground",
                        origin:String(havn_loc.lat)+","+String(havn_loc.lon),
                        baseScene:"Intro scene.scn",
                        activeElements:[],
                        activeParticles: []),
                    TextLayer(
                        duration:1,
                        text:"look around",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:10, width: 100, height: 20),fontSize: 30),
                    MenuLayer(duration: 1, color: "white"),
                    ActionLayer(duration: 1, actions: [
                        ActionLayer.Action(type: "layer", action: "nextPart", runOn: "direct", delay: 10, data: [])
                        
                    ])
                ],
                [//END SCENE 1
                    ChoiceLayer(
                    duration:1,
                    color:CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                    bgcolor:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                    position:CGPoint(x:0,y:-50),
                    buttons:
                    [
                        ChoiceLayer.Button(text:"Neste",action:"nextPart")
                    ]),
                    MenuLayer(duration: 1, color: "white"),
                ]
            ],
            [//MARK: LEVEL2 Fungal network
                [//Find dragon
                    ARLayer(
                        duration:5,
                        originType:"marker",
                        origin:"smarker transparent white",
                        baseScene:"Havn scene.scn",
                        activeElements:[
                            ARLayer.ARActiveElement(title: "scene 2 init marker", pointer: "smarker transparent white", type: "marker", action: "nextPart", active: true)
                    ],activeParticles: []),
                    TextLayer(
                        duration:1,
                        text:"Gå inn for å finne den tohodede dragen",
                        color:CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                        frame:CGRect(x:0,y:10, width: 100, height: 20),fontSize: 30),
                    TextLayer(
                        duration:1,
                        text:"Skann symbolet ved foten av dragen",
                        color:CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                        frame:CGRect(x:0,y:60, width: 100, height: 20),fontSize: 30),
                    ImageLayer(duration: 1, image: "art.scnassets/markers/smarker transparent white.png", frame: CGRect(x: 30, y: 30, width: 40, height: 23), keepAspect: "width", align: "middle"),
                    MenuLayer(duration: 1, color: "white"),
                ],
                [//play dragon video
                    PlayerLayer(
                    duration:1,
                    /*local:false,
                    path:"http://ice-9.no/tests/hellox_vid_1.mp4",*/
                    local: true,
                    path:"scene2film2",
                    endText: "Følg soppnettverket.  \r\nFinn kortene.  \r\nSkriv inn passord på sopptastatur.",
                    endAction:"nextPart")
                ],
                [//find clues
                    HelpLayer(duration: 1, text: "Følg soppnettverket. \r\n Finn kortene. med råd fra symbiontene. \r\nSkriv inn passord  (fra denne regionen) på sopptastatur."),
                    ActionLayer(duration: 1, actions: [
                        //DRAGFORCE
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "direct",
                            delay:0,
                            data:ARLayer.ARForceElement(
                                title:"drag force",
                                position:SCNVector3(0.0,0.0,0.0),
                                strength:30,
                                type:"drag",
                                minDistance: 0
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "direct",
                            delay:0,
                            data:ARLayer.ARForceElement(
                                title:"turbulence force",
                                position:SCNVector3(0.0,0.0,0.0),
                                strength:30,
                                type:"turbulence",
                                minDistance: 0
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "direct",
                            delay:0,
                            data:ARLayer.ARForceElement(
                                title:"vortex force",
                                position:SCNVector3(0.0,0.0,0.0),
                                strength:5,
                                type:"vortex",
                                minDistance: 0
                            )
                        ),
                        
                        //ADD MUSHROOMS
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "direct", data:ARLayer.ARActiveElement(
                                title:          "mushrooms bases",
                                pointer:        "mushroombases.dae",
                                type:           "static",
                                action:         "null",
                                active:         true,
                                position:       SCNVector3(0,0,0),
                                //rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1)
                            )
                        ),
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "direct", data:ARLayer.ARActiveElement(
                                title:          "mushrooms keypad",
                                pointer:        "mushroomcaps.dae",
                                type:           "touch sequence",
                                action:         "mushrooms",
                                                actionData:["keys":
                                                    [
                                                        0:["model":"MUSHROOM-001","display":"G"],
                                                        1:["model":"MUSHROOM-002","display":"I"],
                                                        2:["model":"MUSHROOM-003","display":"F"],
                                                        3:["model":"MUSHROOM-004","display":"T"],
                                                        4:["model":"MUSHROOM-005","display":"X"],
                                                        5:["model":"MUSHROOM-007","display":"U"]
                                                    ],
                                                    "sequence":[0,1,1,3,5],
                                                    "enteredSequence":[]
                                                ],
                                active:         true,
                                position:       SCNVector3(0,0,0),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"tap",
                                actionParticles:"spores")
                        ),
                        
                        
                        //ADD FUNGAL NETWORK PART 1
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "direct", data:ARLayer.ARActiveElement(
                                title:      "fungal network part 1",
                                pointer:    "fungal_1.dae",
                                type:       "static",
                                action:     "null",
                                active:     true,
                                            position:   SCNVector3(0,0.01,0),
                                //rotation:   SCNVector4(0,0,0,0),
                                scale:      SCNVector3(4.155,4.155,4.155))
                            
                        ),
                        
                        //ADD BOWL 1
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "direct", data:ARLayer.ARActiveElement(
                                title:          "bowl 1",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl1",
                                active:         true,
                                position:       SCNVector3(0.35,0,2.3),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"flip")
                                
                            
                        ),
                        //CARD 1 MUSIC
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl1", data:ARLayer.ARActiveElement(
                                title:          "card 1 music",
                                pointer:        "MILIEU.mp3",
                                type:           "music",
                                action:         "play",
                                active:         true,
                                position:       SCNVector3(0.35,0,2.3),
                                rotation:       SCNVector4(0,1,0,1.3),
                                scale:          SCNVector3(0.1,0.1,0.1),
                                actionAnimation:"play")
                                
                            
                        ),
                        
                        //ADD CARD 1
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "direct", data:ARLayer.ARActiveElement(
                                title:          "card 1",
                                pointer:        "card_1.dae",
                                type:           "card",
                                action:         "card1",
                                active:         true,
                                position:       SCNVector3(0.35,0.05,2.3),
                                rotation:       SCNVector4(0,1,0,1.3),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card")
                                
                            
                        ),
                        
                        
                        
                        //ADD FUNGAL NETWORK PART 2 WHEN CARD 1 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card1", data:ARLayer.ARActiveElement(
                                title:      "fungal network part 2",
                                pointer:    "fungal_2.dae",
                                type:       "static",
                                action:     "null",
                                active:     true,
                                position:   SCNVector3(0.0,0.01,0),
                                //rotation:   SCNVector4(0,0,0,0),
                                scale:      SCNVector3(4.155,4.155,4.155))
                            
                        ),
                        
                        //ADD BOWL 2 WHEN CARD 1 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card1", data:ARLayer.ARActiveElement(
                                title:          "bowl 2",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl2",
                                active:         true,
                                position:       SCNVector3(3.05,0,2.25),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"flip")
                                
                            
                        ),
                        //CARD 2 MUSIC
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl2", data:ARLayer.ARActiveElement(
                                title:          "card 2 music",
                                pointer:        "TUNDRA.mp3",
                                type:           "music",
                                action:         "play",
                                active:         true,
                                position:       SCNVector3(3.05,0,2.25),
                                rotation:       SCNVector4(0,1,0,1.3),
                                scale:          SCNVector3(0.1,0.1,0.1),
                                actionAnimation:"play")
                                
                            
                        ),
                        
                        //ADD CARD 2 WHEN CARD 1 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card1", data:ARLayer.ARActiveElement(
                                title:          "card 2",
                                pointer:        "card_2.dae",
                                type:           "card",
                                action:         "card2",
                                active:         true,
                                position:       SCNVector3(3.05,0.05,2.25),
                                rotation:       SCNVector4(0,1,0,1),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card")
                                
                            
                        ),
                        
                        //ADD FUNGAL NETWORK PART 3 WHEN CARD 2 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card2", data:ARLayer.ARActiveElement(
                                title:      "fungal network part 3",
                                pointer:    "fungal_3.dae",
                                type:       "static",
                                action:     "null",
                                active:     true,
                                position:   SCNVector3(0.0,0.01,0),
                                //rotation:   SCNVector4(0,0,0,0),
                                scale:      SCNVector3(4.155,4.155,4.155))
                            
                        ),
                        
                        //ADD BOWL 3 WHEN CARD 2 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card2", data:ARLayer.ARActiveElement(
                                title:          "bowl 3",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl3",
                                active:         true,
                                position:       SCNVector3(0.6,0,-0.3),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"flip")
                                
                            
                        ),
                        
                        //CARD 3 MUSIC
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl3", data:ARLayer.ARActiveElement(
                                title:          "card 3 music",
                                pointer:        "SKOGEN.mp3",
                                type:           "music",
                                action:         "play",
                                active:         true,
                                position:       SCNVector3(0.6,0,-0.3),
                                rotation:       SCNVector4(0,1,0,1.3),
                                scale:          SCNVector3(0.1,0.1,0.1),
                                actionAnimation:"play")
                                
                            
                        ),
                        
                        //ADD CARD 3 WHEN CARD 2 IS CLICKED
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card2", data:ARLayer.ARActiveElement(
                                title:          "card 3",
                                pointer:        "card_3.dae",
                                type:           "card",
                                action:         "card3",
                                active:         true,
                                position:       SCNVector3(0.6,0.05,-0.3),
                                rotation:       SCNVector4(0,1,0,0.1),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card")
                                
                            
                        ),
                        //ADD SPOERES WHEN CORRECT SEQUENCE IS ENTERED
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "mushrooms",
                            data:ARLayer.ARParticleElement(
                                title:"spores",
                                birthRate:500,
                                position:SCNVector3(0.0,0.0,0.0),
                                parent:"mushrooms bases",
                                particleSize:0.002,
                                color: CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "mushrooms",
                            delay:0,
                            data:ARLayer.ARForceElement(
                                title:"radial force",
                                position:SCNVector3(-1.5,1.5,-1.7),
                                strength:80,
                                type:"radial",
                                minDistance: 1.0
                            )
                        ),
                        ActionLayer.Action(type: "layer", action: "nextPart", runOn: "mushrooms", delay: 5, data: [])
                    ]),
                    MenuLayer(duration: 1, color: "white"),
                    
                ],
                [//END SCENE 2
                    ChoiceLayer(
                    duration:1,
                    color:CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                    bgcolor:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                    position:CGPoint(x:0,y:-50),
                    buttons:
                    [
                        ChoiceLayer.Button(text:"Neste",action:"nextPart")
                    ]),
                    MenuLayer(duration: 1, color: "white"),
                ],
                [//play dragon ENDING video
                    PlayerLayer(
                    duration:1,
                    /*local:false,
                    path:"http://ice-9.no/tests/hellox_vid_1.mp4",*/
                    local: true,
                    path:"scene2film3",
                    endText: "",
                    endAction:"nextPart")
                ],
            ],
            [//MARK: LEVEL3 Tree of life
                [
                    MapLayer(
                        duration:1,
                        targetLocation:CLLocation(latitude: radhuset_loc.lat, longitude: radhuset_loc.lon),
                        //targetLocation:CLLocation(latitude: 69.453830, longitude: 18.988221),
                        targetAction:"nextPart",
                        targetTitle:"the tree"
                    ),
                    TextLayer(
                        duration:1,
                        text:"Find tree of life",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        frame:CGRect(x:0,y:10, width: 100, height: 20),fontSize: 30),
                    MenuLayer(duration: 1, color: "white"),
                ],
                /*[
                    MapLayer(
                        duration:1,
                        targetLocation:CLLocation(latitude: 69.637865, longitude: 18.932193
                        
                        
                        
                        ),
                        targetAction:"nextPart",
                        targetTitle:"the tree"
                    ),
                    TextLayer(
                        duration:1,
                        text:"Find tree of life",
                        color:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)),
                ],*/
                [//play video
                    PlayerLayer(
                        duration:1,
                        /*local:false,
                        path:"http://ice-9.no/tests/hellox_vid_1.mp4",*/
                        local: true,
                        path:"scene3film4",
                        endText: "Finn kortene med råd fra symbiontene. Trykk ‘?’ for tips",
                        endAction:"nextPart")
                ],
                [//Loading
                    ActionLayer(duration: 1, actions: [
                        ActionLayer.Action(type: "layer", action: "nextPart", runOn: "direct", delay: 1, data: [])
                        
                    ])
                ],
                [//set up tree scene
                    ARLayer(
                        duration:3,
                        originType:"ground",
                        origin:String(radhuset_loc.lat)+","+String(radhuset_loc.lon),
                        //baseScene:"TreeOfLife scene.scn",
                        baseScene:"scene3.scn",
                        activeElements:[
                            ARLayer.ARActiveElement(//CHILD SITTING
                                title:          "sitting cild",
                                pointer:        "childsitting.dae",
                                type:           "static",
                                action:         "bowl4",
                                active:         true,
                                position:       SCNVector3(0.0,0,-0.6),
                                //rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"static"),
                            ARLayer.ARActiveElement(//BOWL 1
                                title:          "bowl 4",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl4",
                                active:         true,
                                position:       SCNVector3(-1.0,0,-0.25),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1.7,1.7,1.7),
                                actionAnimation:"flipbig"),
                            
                            ARLayer.ARActiveElement(//BOWL 2
                                title:          "bowl 5",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl5",
                                active:         true,
                                position:       SCNVector3(1.0,0,-0.25),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1.7,1.7,1.7),
                                actionAnimation:"flipbig"),
                            ARLayer.ARActiveElement(//BOWL 3
                                title:          "bowl 6",
                                pointer:        "bowlfung.dae",
                                type:           "touch",
                                action:         "bowl6",
                                active:         true,
                                position:       SCNVector3(0.0,0,1.2),
                                rotation:       SCNVector4(0,0,0,0.0),
                                scale:          SCNVector3(1.7,1.7,1.7),
                                actionAnimation:"flipbig"),
                            ARLayer.ARActiveElement(//CARD 4
                                title:          "card 4",
                                pointer:        "card_4.dae",
                                type:           "card",
                                action:         "card4",
                                active:         true,
                                position:       SCNVector3(-1.0,0,-0.25),
                                rotation:       SCNVector4(0,1,0,0.4),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card"),
                            ARLayer.ARActiveElement(//CARD 5
                                title:          "card 5",
                                pointer:        "card_5.dae",
                                type:           "card",
                                action:         "card5",
                                active:         true,
                                position:       SCNVector3(1.0,0,-0.25),
                                rotation:       SCNVector4(0,1,0,0.4),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card"),
                            ARLayer.ARActiveElement(//CARD 6
                                title:          "card 6",
                                pointer:        "card_6.dae",
                                type:           "card",
                                action:         "card6",
                                active:         true,
                                position:       SCNVector3(0.0,0,1.2),
                                rotation:       SCNVector4(0,1,0,0.4),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"card"),
                            /*ARLayer.ARActiveElement(//SEED 1
                                title:          "seed 1",
                                pointer:        "seed_1.dae",
                                type:           "dragndrop",
                                action:         "seed1",
                                actionDelay:    1,
                                actionData:     "seed1drop",
                                active:         true,
                                position:       SCNVector3(-0.45,0,-0.25),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed"),
                            ARLayer.ARActiveElement(//SEED 2
                                title:          "seed 2",
                                pointer:        "seed_2.dae",
                                type:           "dragndrop",
                                action:         "seed2",
                                actionDelay:    1,
                                actionData:     "seed2drop",
                                active:         true,
                                position:       SCNVector3(0.45,0,-0.25),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed"),
                            ARLayer.ARActiveElement(//SEED 3
                                title:          "seed 3",
                                pointer:        "seed_3.dae",
                                type:           "dragndrop",
                                action:         "seed3",
                                actionDelay:    1,
                                actionData:     "seed3drop",
                                active:         true,
                                position:       SCNVector3(-0.05,0,0.6),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed"),*/
                            ARLayer.ARActiveElement(//SEED DROP 1
                                title:          "seed 1 dropzone",
                                pointer:        "seeddrop1.dae",
                                type:           "dropzone",
                                action:         "seed1drop",
                                active:         true,
                                position:       SCNVector3(-0.01,0.7,-0.57),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"dropzone"),
                            ARLayer.ARActiveElement(//SEED DROP 1
                                title:          "seed 2 dropzone",
                                pointer:        "seeddrop2.dae",
                                type:           "dropzone",
                                action:         "seed2drop",
                                active:         true,
                                position:       SCNVector3(0.0,0.42,-0.65),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"dropzone"),
                            ARLayer.ARActiveElement(//SEED DROP 1
                                title:          "seed 3 dropzone",
                                pointer:        "seeddrop3.dae",
                                type:           "dropzone",
                                action:         "seed3drop",
                                active:         true,
                                position:       SCNVector3(-0.3,0.17,-0.4735),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"dropzone"),
                    ],activeParticles: []),
                        ActionLayer(duration: 1, actions: [
                            //CARD 4 MUSIC
                            ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl4", data:ARLayer.ARActiveElement(
                                    title:          "card 4 music",
                                    pointer:        "KYST.mp3",
                                    type:           "music",
                                    action:         "play",
                                    active:         true,
                                    position:       SCNVector3(-1.1,0.0,-0.25),
                                    rotation:       SCNVector4(0,1,0,1.3),
                                    scale:          SCNVector3(0.1,0.1,0.1),
                                    actionAnimation:"play")
                                    
                                
                            ),
                            //CARD 5 MUSIC
                            ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl5", data:ARLayer.ARActiveElement(
                                    title:          "card 5 music",
                                    pointer:        "MARINT.mp3",
                                    type:           "music",
                                    action:         "play",
                                    active:         true,
                                    position:       SCNVector3(1.1,0.0,-0.25),
                                    rotation:       SCNVector4(0,1,0,1.3),
                                    scale:          SCNVector3(0.1,0.1,0.1),
                                    actionAnimation:"play")
                                    
                                
                            ),
                            //CARD 6 MUSIC
                            ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "bowl6", data:ARLayer.ARActiveElement(
                                    title:          "card 6 music",
                                    pointer:        "URBANT.mp3",
                                    type:           "music",
                                    action:         "play",
                                    active:         true,
                                    position:       SCNVector3(0.0,0.0,1.3),
                                    rotation:       SCNVector4(0,1,0,1.3),
                                    scale:          SCNVector3(0.1,0.1,0.1),
                                    actionAnimation:"play")
                                    
                                
                            ),
                        //ADD SEED 1
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card4", data:ARLayer.ARActiveElement(//SEED 1
                                title:          "seed 1",
                                pointer:        "seed_1.dae",
                                type:           "dragndrop",
                                action:         "seed1",
                                actionDelay:    1,
                                actionData:     "seed1drop",
                                active:         true,
                                position:       SCNVector3(-0.9,0,-0.2),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed")
                        ),
                        //ADD SEED 2
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card5", data:ARLayer.ARActiveElement(//SEED 1
                                title:          "seed 2",
                                pointer:        "seed_2.dae",
                                type:           "dragndrop",
                                action:         "seed2",
                                actionDelay:    1,
                                actionData:     "seed2drop",
                                active:         true,
                                position:       SCNVector3(0.9,0,-0.2),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed")
                        ),
                        //ADD SEED 3
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "card6", data:ARLayer.ARActiveElement(//SEED 1
                                title:          "seed 3",
                                pointer:        "seed_3.dae",
                                type:           "dragndrop",
                                action:         "seed3",
                                actionDelay:    1,
                                actionData:     "seed3drop",
                                active:         true,
                                position:       SCNVector3(-0.05,0,1.3),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(0.5,0.5,0.5),
                                actionAnimation:"seed")
                        ),
                        
                        ActionLayer.Action(
                            type: "action",
                            action: "seeddrop",
                            runOn:"seed1drop",
                            data:[]),
                        ActionLayer.Action(
                            type: "action",
                            action: "seeddrop",
                            runOn:"seed2drop",
                            data:[]),
                        ActionLayer.Action(
                            type: "action",
                            action: "seeddrop",
                            runOn:"seed3drop",
                            data:[]),
                        
                        
                        ActionLayer.Action(
                            type: "action",
                            action: "allplanted",
                            runOn:"seeddrop",
                            data:[],
                            capacity:3),
                        
                        //ADD PARTICLES WHEN SEEDS ARE PLANTED
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "seed1drop",
                            data:ARLayer.ARParticleElement(
                                title:"seed 1 particles",
                                birthRate:100,
                                position:SCNVector3(0.0,0.7,-0.57),
                                parent:nil,
                                particleSize:0.001,
                                color: CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "seed1drop",
                            data:["seed 1","seed 1 dropzone"]
                        ),
                        
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "seed2drop",
                            data:ARLayer.ARParticleElement(
                                title:"seed 2 particles",
                                birthRate:100,
                                position:SCNVector3(0.0,0.42,-0.6),
                                parent:nil,
                                particleSize:0.001,
                                color: CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "seed2drop",
                            data:["seed 2","seed 2 dropzone"]
                        ),
                        
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "seed3drop",
                            data:ARLayer.ARParticleElement(
                                title:"seed 3 particles",
                                birthRate:100,
                                position:SCNVector3(-0.3,0.17,-0.4735),
                                parent:nil,
                                particleSize:0.002,
                                color: CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "seed3drop",
                            data:["seed 3","seed 3 dropzone"]
                        ),
                        
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "allplanted",
                            delay:8,
                            data:ARLayer.ARForceElement(
                                title:"radial force",
                                position:SCNVector3(3.75,1.7,1.39),
                                strength:100,
                                type:"radial",
                                minDistance: 0.5
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "allplanted",
                            data:["card 1 music","card 2 music", "card 3 music"]
                        ),
                        //TREE MUSIC
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "allplanted", data:ARLayer.ARActiveElement(
                                title:          "tree music",
                                pointer:        "3MINUTESV2.mp3",
                                type:           "music",
                                action:         "play",
                                active:         true,
                                            position:       SCNVector3(0.0,1.0,0.0),
                                rotation:       SCNVector4(0,1,0,1.3),
                                scale:          SCNVector3(0.1,0.1,0.1),
                                actionAnimation:"play")
                                
                            
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "allplanted",
                            delay:5,
                            data:ARLayer.ARForceElement(
                                title:"radial force big",
                                position:SCNVector3(3.75,1.7,1.39),
                                strength:1600,
                                type:"radial",
                                minDistance: 2
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "allplanted",
                            delay:8,
                            data:ARLayer.ARForceElement(
                                title:"vortex force",
                                position:SCNVector3(0.0,0.0,-3.0),
                                strength:50,
                                type:"vortex",
                                minDistance: 0
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "allplanted",
                            delay:3,
                            data:ARLayer.ARForceElement(
                                title:"turbulence force",
                                position:SCNVector3(1.5,2.25,-3.0),
                                strength:20,
                                type:"turbulence",
                                minDistance: 0
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARForceElement",
                            runOn: "allplanted",
                            delay:8,
                            data:ARLayer.ARForceElement(
                                title:"drag force",
                                position:SCNVector3(1.5,2.25,-3.0),
                                strength:30,
                                type:"drag",
                                minDistance: 0
                            )
                        ),
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "allplanted",
                            delay: 2,
                            data:["sitting cild","seed 1 particles","seed 2 particles","seed 3 particles"]
                        ),
                         
                        //ADD YELLOW FUNGAL
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "seed3drop", data:ARLayer.ARActiveElement(
                                title:          "yellow fungal",
                                pointer:        "fungalyellow.dae",
                                type:           "sequence",
                                action:         "fungalyellow",
                                active:         true,
                                position:       SCNVector3(0.0,0.01,0.0),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"framebyframe",
                                inDuration:     10.0)
                                
                            
                        ),
                        //ADD YELLOW PARTICLES
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "allplanted",
                            delay: 3,
                            data:ARLayer.ARParticleElement(
                                title:"yellow particles",
                                birthRate:100,
                                position:SCNVector3(0.0,0.0,0.0),
                                parent:"yellow fungal",
                                particleSize:0.005,
                                color: CGColor(srgbRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        //ADD GREEN FUNGAL
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "seed1drop", data:ARLayer.ARActiveElement(
                                title:          "green fungal",
                                pointer:        "fungalgreen.dae",
                                type:           "sequence",
                                action:         "fungalgreen",
                                active:         true,
                                position:       SCNVector3(0.0,-0.01,0.0),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"framebyframe",
                                inDuration:     9.0)
                                
                            
                        ),
                        //ADD GREEN PARTICLES
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "allplanted",
                            delay: 3,
                            data:ARLayer.ARParticleElement(
                                title:"green particles",
                                birthRate:100,
                                position:SCNVector3(0.0,0.0,0.0),
                                parent:"green fungal",
                                particleSize:0.005,
                                color: CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        //ADD RED FUNGAL
                        ActionLayer.Action(type: "AR", action: "addARActiveElement", runOn: "seed2drop", data:ARLayer.ARActiveElement(
                                title:          "red fungal",
                                pointer:        "fungalred.dae",
                                type:           "sequence",
                                action:         "fungalred",
                                active:         true,
                                position:       SCNVector3(0.0,0.0,0.0),
                                rotation:       SCNVector4(0,0,0,0),
                                scale:          SCNVector3(1,1,1),
                                actionAnimation:"framebyframe",
                                inDuration:     9.5)
                                
                            
                        ),
                        //ADD RED PARTICLES
                        ActionLayer.Action(
                            type: "AR",
                            action: "addARParticleElement",
                            runOn: "allplanted",
                            delay: 3,
                            data:ARLayer.ARParticleElement(
                                title:"red particles",
                                birthRate:100,
                                position:SCNVector3(0.0,0.0,0.0),
                                parent:"red fungal",
                                particleSize:0.005,
                                color: CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                            )
                        ),
                        //ADD LEAF
                        ActionLayer.Action(type: "AR",
                                           action: "addARActiveElement",
                                           runOn: "allplanted",
                                           delay: 10,
                                           data:ARLayer.ARActiveElement(
                                                title:          "leaf",
                                                pointer:        "leafpassword.dae",
                                                type:           "touch",
                                                action:         "nextPart",
                                                active:         true,
                                                position:       SCNVector3(3.75,1.7,1.39),
                                                rotation:       SCNVector4(0.2,0.8,0.5,Double.pi*0.8),
                                                scale:          SCNVector3(1,1,1),
                                                inDuration:     1.0)
                                
                            
                        ),
                            
                        
                    ]),
                    HelpLayer(duration: 1, text: "Trykk på frøet for å plukke det opp. \r\nPlanter hvert frø, ett om gangen, ved å skyve enheten inn i den fargede 'drop zone'. (Ingen 'trykk' eller 'dra' kreves)\r\nFrøet vil forsvinne når det plantes.\r\nPlanter alle tre frøene for å finne passordet som låser opp plasseringen av boken.\r\nBerør bladet"),
                    MenuLayer(duration: 1, color: "white"),
                ],
                [//PLAY FINAL VIDEO
                    PlayerLayer(
                        duration:1,
                        /*local:false,
                        path:"http://ice-9.no/tests/hellox_vid_1.mp4",*/
                        local: true,
                        path:"scene3film5",
                        endText: "Ta skjermbilde eller skriv ned passord.",
                        endAction:"nextPart")
                ],
                [
                    ActionLayer(duration: 1, actions: [
                        ActionLayer.Action(
                            type: "AR",
                            action: "removeARActiveElements",
                            runOn: "direct",
                            data:["leaf"]
                        ),
                        //ADD LEAF
                        ActionLayer.Action(type: "AR",
                                           action: "addARActiveElement",
                                           runOn: "direct",
                                           delay: 0,
                                           data:ARLayer.ARActiveElement(
                                                title:          "leafpassword",
                                                pointer:        "leafpassword.dae",
                                                type:           "static",
                                                action:         "leaf",
                                                active:         true,
                                                position:       SCNVector3(3.75,1.7,1.39),
                                                rotation:       SCNVector4(0.2,0.8,0.5,Double.pi*0.8),
                                                scale:          SCNVector3(1,1,1),
                                                inDuration:     1.0)
                                
                            
                        ),
                    ]),
                    ChoiceLayer(duration: 1,
                            color: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1),
                            bgcolor:CGColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
                            position:CGPoint(x:0,y:-50),
                            buttons: [ChoiceLayer.Button(text: "hellox.me/book",
                                                         action: "website")]),
                    MenuLayer(duration: 1, color: "white"),
                    
                ]
            ]
        ]
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
    func setupLevels()
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
        
        
    }
    
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
        let part=levels[currentLevel][currentPart]
        
        for layer in part
        {
            print("layer")
            layer.putUp()
            print(layer)
        }
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
