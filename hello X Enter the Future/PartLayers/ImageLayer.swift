//
//  ImageLayer.swift
//  testar
//
//  Created by diego on 6/11/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class ImageLayer: PartLayerClass
{
    
    var layer:CALayer?
    
    var frame:CGRect
    
    var keepAspect:String
    var align:String
    var aspect=1.0
    
    var imageWidth:Double
    var imageHeight:Double
    
    init(duration:Int, image:String, frame: CGRect, keepAspect: String, align: String )
    {
        
        self.keepAspect=keepAspect
        self.align=align
        layer           = CALayer()
        self.frame      = frame
        let cgimage     = UIImage(named: image)?.cgImage
        //TODO correct aspect ratio
        imageWidth  = Double(cgimage!.width)
        imageHeight  = Double(cgimage!.height)
        aspect=Double(imageWidth/imageHeight)
        layer!.contents = cgimage
        
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        let viewBounds=self.view!.bounds
        var frameX=frame.origin.x/100*viewBounds.width
        var frameY=frame.origin.y/100*viewBounds.height
        var frameW=frame.width/100*viewBounds.width
        var frameH=frame.height/100*viewBounds.height
        
        switch keepAspect
        {
            case "none":
                frameW=frame.width/100*viewBounds.width
                frameH=frame.height/100*viewBounds.height
            case "width":
                frameH=frame.height/100*viewBounds.height
                frameW=frameH*CGFloat(aspect)
            default:
                frameW=CGFloat(imageWidth)
                frameH=CGFloat(imageHeight)
        }
        switch align {
        case "middle":
            frameX=(viewBounds.width-frameW)/2
        default:
            frameX=frame.origin.x
            frameY=frame.origin.y
        }
        let newFrame=CGRect(x: frameX, y: frameY, width: frameW, height: frameH)
        
        
        layer!.frame=newFrame
        self.view?.layer.addSublayer(layer!)
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            
            return
        }
        layer!.removeFromSuperlayer()
        
        super.takeDown()
    }
}
