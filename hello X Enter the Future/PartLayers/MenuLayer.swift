//
//  MenuLayer.swift
//  hello X Enter the Future
//
//  Created by Jegor Sushko on 2021-04-29.
//

import Foundation
import UIKit


class MenuLayer: PartLayerClass
{
    var layer:CALayer?
    
    let defaults = UserDefaults.standard
    var isLevel2Unlocked=false
    var isLevel3Unlocked=false
    
    var showMenuString = "showmenu"
    var showMenuAction:LevelController.ActionArea?
    
    var menuHidden=true
    
    var level1String = "setlevel1"
    var level1Action:LevelController.ActionArea?
    var level2String = "setlevel2"
    var level2Action:LevelController.ActionArea?
    var level3String = "setlevel3"
    var level3Action:LevelController.ActionArea?
    
    var unlockRange = "unlockrange"
    var unlockrangeAction:LevelController.ActionArea?
    
    var exit = "exitaction"
    var exitAction:LevelController.ActionArea?
    
    
    
    var menuButtonColor:String!
    
    
    init(duration:Int, color:String){
        layer=CALayer()

        menuButtonColor=color
        
        layer?.backgroundColor=UIColor.white.cgColor
        layer?.borderColor=UIColor.black.cgColor
        layer?.borderWidth=1

        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        let mainBounds=view!.bounds
        
        let menuimage     = UIImage(named: "art.scnassets/images/yellowbk.png")?.cgImage
        
        let imageWidth  = Double(menuimage!.width)
        let imageHeight  = Double(menuimage!.height)
        let aspect=imageWidth/imageHeight
        print (aspect)
        layer!.frame.size.height=mainBounds.height
        layer!.frame.size.width=layer!.frame.size.height*CGFloat(aspect)
        layer!.contents=menuimage
        layer!.frame.origin=CGPoint(x:(mainBounds.width-layer!.frame.size.width)/2,y:0)
        
        
        layer!.isHidden=true
        
        view!.layer.addSublayer(layer!)
    
        
        levelController!.activeMenuLayer=self
        
        let showMenuButton      = CALayer()
        let menubtnimage        = UIImage(named: "art.scnassets/images/menubtn.png")?.cgImage
        let menubtnimageblack   = UIImage(named: "art.scnassets/images/menublckbtn.png")?.cgImage
        if menuButtonColor == "black"{
            showMenuButton.contents = menubtnimageblack
        }else{
            showMenuButton.contents = menubtnimage
        }
        
        showMenuButton.frame.origin=CGPoint(x:5,y:20)
        showMenuButton.frame.size.width=40
        showMenuButton.frame.size.height=40
        showMenuButton.isHidden=false
        
        showMenuAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: showMenuButton, action: showMenuString,active:true)
        levelController!.addActionArea(actionArea:showMenuAction!)
        view!.layer.addSublayer(showMenuButton)
        
        let level1Button = CALayer()
        let lvl1btnimage     = UIImage(named: "art.scnassets/images/test button 1.png")?.cgImage
        level1Button.contents = lvl1btnimage
        level1Button.frame.origin=CGPoint(x:mainBounds.width*0.5-60,y:60)
        level1Button.frame.size.width=120
        level1Button.frame.size.height=142
        level1Button.isHidden=true
        
        level1Action=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: level1Button, action: level1String,active:false)
        levelController!.addActionArea(actionArea:level1Action!)
        view!.layer.addSublayer(level1Button)
        
        isLevel2Unlocked = defaults.bool(forKey: "level2unlocked")
        let level2Button = CALayer()
        let lvl2btnimage     = UIImage(named: "art.scnassets/images/test button 2.png")?.cgImage
        level2Button.contents = lvl2btnimage
        level2Button.frame.origin=CGPoint(x:mainBounds.width*0.5-123,y:170)
        level2Button.frame.size.width=120
        level2Button.frame.size.height=142
        level2Button.isHidden=true
        
        if !isLevel2Unlocked
        {
            level2Button.opacity=0.3
        }
        level2Action=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: level2Button, action: level2String,active:false)
        levelController!.addActionArea(actionArea:level2Action!)
        view!.layer.addSublayer(level2Button)
        
        isLevel3Unlocked = defaults.bool(forKey: "level3unlocked")
        let level3Button = CALayer()
        let lvl3btnimage     = UIImage(named: "art.scnassets/images/test button 3.png")?.cgImage
        level3Button.contents = lvl3btnimage
        level3Button.frame.origin=CGPoint(x:mainBounds.width*0.5+3,y:170)
        level3Button.frame.size.width=120
        level3Button.frame.size.height=142
        level3Button.isHidden=true
        
        if !isLevel3Unlocked
        {
            level3Button.opacity=0.3
        }
        level3Action=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: level3Button, action: level3String,active:false)
        levelController!.addActionArea(actionArea:level3Action!)
        view!.layer.addSublayer(level3Button)
        
        
        let unlockRangeButton = CALayer()
        let unlockRangeImage     = UIImage(named: "art.scnassets/images/test button 1.png")?.cgImage
        unlockRangeButton.contents = unlockRangeImage
        unlockRangeButton.frame.origin=CGPoint(x:mainBounds.width*0.5-60,y:mainBounds.height-80)
        unlockRangeButton.frame.size.width=120
        unlockRangeButton.frame.size.height=120
        unlockRangeButton.isHidden=true
        unlockRangeButton.opacity=0
        
        
        unlockrangeAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: unlockRangeButton, action: unlockRange,active:false)
        levelController!.addActionArea(actionArea:unlockrangeAction!)
        view!.layer.addSublayer(unlockRangeButton)
        
        
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            return
        }
        layer!.removeFromSuperlayer()
        
        (showMenuAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:showMenuAction!)
        
        (level1Action!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:level1Action!)
        (level2Action!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:level2Action!)
        (level3Action!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:level3Action!)
        
        (unlockrangeAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:unlockrangeAction!)
        
                
        
        
        levelController!.activeMenuLayer=nil
        
        super.takeDown()
    }
    
    func showMenu(){
        if menuHidden
        {
            menuHidden=false
            layer!.isHidden=false
            level1Action?.active=true
            (level1Action?.pointer as! CALayer).isHidden=false
            if isLevel2Unlocked
            {
                level2Action?.active=true
            }
            (level2Action?.pointer as! CALayer).isHidden=false
            if isLevel3Unlocked
            {
                level3Action?.active=true
            }
            (level3Action?.pointer as! CALayer).isHidden=false
            
            unlockrangeAction?.active=true
            (unlockrangeAction?.pointer as! CALayer).isHidden=false
            

            let menubtnimage = UIImage(named: "art.scnassets/images/menublckbtn.png")?.cgImage
            
            (showMenuAction!.pointer as! CALayer).contents = menubtnimage
            
        }else{
            menuHidden=true
            layer!.isHidden=true
            level1Action?.active=false
            (level1Action?.pointer as! CALayer).isHidden=true
            level2Action?.active=false
            (level2Action?.pointer as! CALayer).isHidden=true
            level3Action?.active=false
            (level3Action?.pointer as! CALayer).isHidden=true
            
            unlockrangeAction?.active=false
            (unlockrangeAction?.pointer as! CALayer).isHidden=true
            
            
            var menubtnimage:CGImage?
            if menuButtonColor == "black"{
                menubtnimage = UIImage(named: "art.scnassets/images/menublckbtn.png")?.cgImage
            }else{
                menubtnimage = UIImage(named: "art.scnassets/images/menubtn.png")?.cgImage
            }
            (showMenuAction!.pointer as! CALayer).contents = menubtnimage
        }
        
        
        
    }
    
    
}
