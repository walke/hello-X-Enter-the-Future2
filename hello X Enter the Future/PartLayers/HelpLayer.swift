//
//  HelpLayer.swift
//  hello X Enter the Future
//
//  Created by Jegor Sushko on 2021-04-29.
//

import Foundation
import UIKit

class HelpLayer: PartLayerClass
{
    var layer:CALayer?
    var textLayer:CATextLayer?
    
    var showHelpString = "showhelp"
    var showHelpAction:LevelController.ActionArea?
    
    var hideHelpString = "hidehelp"
    var hideHelpAction:LevelController.ActionArea?
    

    
    
    init(duration:Int, text:String){
        layer=CALayer()
        textLayer=CATextLayer()
        
        layer?.backgroundColor=UIColor.white.cgColor
        layer?.borderColor=UIColor.black.cgColor
        layer?.borderWidth=1
        
        textLayer?.string=text
        textLayer?.fontSize=24
        textLayer?.foregroundColor=UIColor.black.cgColor
        textLayer?.isWrapped=true
        textLayer?.alignmentMode = .center
        
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        let mainBounds=view!.bounds
        
        layer!.frame.origin=CGPoint(x:mainBounds.width*0.05,y:mainBounds.height*0.1)
        layer!.frame.size.width=mainBounds.width*0.9
        layer!.frame.size.height=mainBounds.height*0.8
        layer!.isHidden=true
        
        view!.layer.addSublayer(layer!)
        
        textLayer!.frame.origin=CGPoint(x:mainBounds.width*0.1,y:mainBounds.height*0.2)
        textLayer!.frame.size.width=mainBounds.width*0.8
        textLayer!.frame.size.height=mainBounds.height*0.6
        textLayer!.isHidden=true
        
        view!.layer.addSublayer(textLayer!)
        
        levelController!.activeHelpLayer=self
        
        let showHelpButton = CALayer()
        let helpimage     = UIImage(named: "art.scnassets/images/helpbtn.png")?.cgImage
        showHelpButton.contents = helpimage
        showHelpButton.frame.origin=CGPoint(x:mainBounds.width-45,y:20)
        showHelpButton.frame.size.width=40
        showHelpButton.frame.size.height=40
        showHelpButton.isHidden=false
        
        showHelpAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: showHelpButton, action: showHelpString,active:true)
        levelController!.addActionArea(actionArea:showHelpAction!)
        view!.layer.addSublayer(showHelpButton)
        
        let hideHelpButton = CALayer()
        let crossimage     = UIImage(named: "art.scnassets/images/crossbtn.png")?.cgImage
        hideHelpButton.contents = crossimage
        hideHelpButton.frame.origin=CGPoint(x:mainBounds.width*0.95-45,y:mainBounds.height*0.1+5)
        hideHelpButton.frame.size.width=40
        hideHelpButton.frame.size.height=40
        hideHelpButton.isHidden=true
        
        hideHelpAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: hideHelpButton, action: hideHelpString,active:false)
        levelController!.addActionArea(actionArea:hideHelpAction!)
        view!.layer.addSublayer(hideHelpButton)
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            return
        }
        layer!.removeFromSuperlayer()
        textLayer!.removeFromSuperlayer()
        
        (showHelpAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:showHelpAction!)
        (hideHelpAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:hideHelpAction!)
                
        
        
        levelController!.activeHelpLayer=nil
        
        super.takeDown()
    }
    
    func showHelp(){
        layer!.isHidden=false
        textLayer!.isHidden=false
        hideHelpAction?.active=true
        (hideHelpAction?.pointer as! CALayer).isHidden=false
    }
    
    func hideHelp(){
        layer!.isHidden=true
        textLayer!.isHidden=true
        hideHelpAction?.active=false
        (hideHelpAction?.pointer as! CALayer).isHidden=true
    }
}
