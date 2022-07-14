//
//  ChoiceLayer.swift
//  testar
//
//  Created by diego on 6/5/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class ChoiceLayer: PartLayerClass
{
    var buttons:[Button]=[]
    
    var position:CGPoint
    
    struct Button
    {
        var text    = ""
        var action  = ""
        var layer:CATextLayer?
        var actionArea:LevelController.ActionArea?
    }
    
    init(duration:Int, color:CGColor, bgcolor: CGColor, position:CGPoint, buttons:[Button])
    {
        
        
        //var buttonNumber=0//TODO multi-button layer
        self.position=position
        for button in buttons
        {
            let layer=CATextLayer()
            let newButton=Button(
                text:button.text,
                action: button.action,
                layer: layer,
                actionArea: LevelController.ActionArea(
                    type:"layer",
                    priority: 0,
                    pointer: layer,
                    action: button.action,
                    active: true))
            //newButton.layer = CATextLayer()
            newButton.layer!.string=button.text
            newButton.layer!.fontSize=45
            newButton.layer!.foregroundColor=color
            newButton.layer!.backgroundColor=bgcolor
            newButton.layer!.borderColor=color
            newButton.layer!.alignmentMode=CATextLayerAlignmentMode.center
            newButton.layer!.borderWidth=2
            newButton.layer!.contentsScale = UIScreen.main.scale
            self.buttons.append(newButton)
            //print(newButton)
        }
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        let mainBounds=view!.bounds
        let buttonWidth=mainBounds.width/CGFloat(self.buttons.count)
        
        for button in self.buttons
        {
            
            
            button.layer!.frame.origin=CGPoint(x:self.position.x,y:mainBounds.height+self.position.y)
            button.layer!.frame.size.width=buttonWidth
            button.layer!.frame.size.height=50
            //print(button)
            view!.layer.addSublayer(button.layer!)
            
            levelController!.addActionArea(actionArea:button.actionArea!)
            
        }
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            
            return
        }
        for button in self.buttons
        {
            button.layer?.removeFromSuperlayer()
            
            levelController!.removeActionArea(actionArea:button.actionArea!)
        }
        
        super.takeDown()
    }
}
