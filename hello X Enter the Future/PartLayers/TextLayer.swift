//
//  TextLayer.swift
//  testar
//
//  Created by diego on 6/5/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class TextLayer: PartLayerClass
{
    
    var layer:CATextLayer
    var frame:CGRect
    var fontSize:CGFloat
    
    init(duration:Int, text:String, color:CGColor, frame:CGRect, fontSize:CGFloat)
    {
        
        
        layer       = CATextLayer()
        layer.string=text
        layer.foregroundColor=color
        layer.alignmentMode=CATextLayerAlignmentMode.center
        
        self.frame=frame
        self.fontSize=fontSize
        
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        let viewBounds=self.view!.bounds
        let frameX=frame.origin.x/100*viewBounds.width
        let frameY=frame.origin.y/100*viewBounds.height
        let frameW=frame.width/100*viewBounds.width
        let frameH=frame.height/100*viewBounds.height
        
        //layer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let newFrame=CGRect(x: frameX, y: frameY, width: frameW, height: frameH)
        
        layer.frame=newFrame
        layer.fontSize=self.fontSize
        layer.isWrapped=true
        //layer.frame.origin=self.frame
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        layer.contentsScale = UIScreen.main.scale
        
        
        
        self.view?.layer.addSublayer(layer)
        layer.add(animation, forKey: "opacity")
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            
            return
        }
        layer.removeFromSuperlayer()
        
        super.takeDown()
    }
}
