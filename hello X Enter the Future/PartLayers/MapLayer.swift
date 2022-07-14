//
//  MapLayer.swift
//  testar
//
//  Created by diego on 6/7/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapLayer: PartLayerClass
{
    var layer:MKMapView?
    
    var targetLocation:CLLocation?
    var targetAction:String?
    var targetTitle:String?
    
    var lastKnownLocation:CLLocation?
    var currentLevelRegion:MKCoordinateRegion?
    let regionUpdateThreshold   = 0.001
    var targetEntranceThreshold = 0.0001
    
    var mapAction:LevelController.ActionArea?
    let enterButton = CATextLayer()
    
    init(duration:Int,targetLocation:CLLocation,targetAction:String,targetTitle:String)
    {
        //layer           = MKMapView()
        
        self.targetLocation=targetLocation
        self.targetAction=targetAction
        self.targetTitle=targetTitle

        
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        if levelController!.mapView == nil
        {
            levelController!.mapView = MKMapView()
            //levelController!.mapView=layer
        }
        layer=levelController!.mapView!
        layer!.frame=self.view!.bounds
        layer!.showsUserLocation=true
        
        levelController!.activeMapLayer=self
        
        let annotation = PlaceAnnotation(location: self.targetLocation!.coordinate, title: self.targetTitle!)
        layer!.addAnnotation(annotation)
        
        let mainBounds=view!.bounds
        
        view!.addSubview(layer!)
       
        
        enterButton.string="enter"
        enterButton.fontSize=45
        enterButton.foregroundColor=UIColor.red.cgColor
        enterButton.alignmentMode=CATextLayerAlignmentMode.center
        enterButton.frame.origin=CGPoint(x:mainBounds.width/4,y:mainBounds.height-60)
        enterButton.frame.size.width=mainBounds.width/2
        enterButton.frame.size.height=50
        enterButton.borderColor=UIColor.red.cgColor
        enterButton.borderWidth=2
        enterButton.isHidden=true
        
        mapAction=LevelController.ActionArea(type:"layer",priority: 0, pointer: enterButton, action: targetAction!,active:false)
        
        levelController!.addActionArea(actionArea:mapAction!)
        
        layer!.layer.addSublayer(enterButton)
        
        levelController!.delegate!.currentPositionUpdater(state:true)
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            
            return
        }
        
        layer!.removeAnnotations(layer!.annotations)
        enterButton.removeFromSuperlayer()
        
        layer!.removeFromSuperview()
        levelController!.removeActionArea(actionArea:mapAction!)
        levelController!.delegate!.currentPositionUpdater(state:false)
        
        levelController!.activeMapLayer=nil
        
        levelController!.lastKnownLocation=nil
        
        
        super.takeDown()
        
    }
    
    func locationUpdated()
    {
        
        if targetLocation != nil
        {
            let dlat=targetLocation!.coordinate.latitude-lastKnownLocation!.coordinate.latitude
            let dlon=targetLocation!.coordinate.longitude-lastKnownLocation!.coordinate.longitude
            let dloc=sqrt(dlat*dlat+dlon*dlon)
            
            let span = MKCoordinateSpan(latitudeDelta: dloc*1.5, longitudeDelta: dloc*1.5)
            let mid = CLLocationCoordinate2D(latitude: lastKnownLocation!.coordinate.latitude+dlat/2, longitude: lastKnownLocation!.coordinate.longitude+dlon/2)
            let region = MKCoordinateRegion(center: mid, span: span)
            
            if(currentLevelRegion==nil)
            {
                
                currentLevelRegion=region
                
                layer!.setRegion(region, animated: true)
                
            }
            else
            {
                let rdlat=region.center.latitude-currentLevelRegion!.center.latitude
                let rdlon=region.center.longitude-currentLevelRegion!.center.longitude
                let rdloc=sqrt(rdlat*rdlat+rdlon*rdlon)
                
                if(rdloc<regionUpdateThreshold)
                {
                    currentLevelRegion=region
                    
                    layer!.setRegion(region, animated: true)
                        
                    
                }
            }
            //print("dloc: \(dloc)")
            if(dloc<targetEntranceThreshold)
            {
                
                mapAction?.active=true
                (mapAction?.pointer as! CALayer).isHidden=false
                //print("activate enter \(mapAction?.active)")
            }
            else
            {
                mapAction?.active=false
                (mapAction?.pointer as! CALayer).isHidden=true
            }
            
            
        }
        
         
    }
}
