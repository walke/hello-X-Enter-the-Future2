//
//  SolidLayer.swift
//  testar
//
//  Created by diego on 6/5/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class SolidLayer: PartLayerClass
{
    var layer:CALayer
    
    init(duration:Int, color:CGColor)
    {
        
        
        
        layer           = CALayer()
        layer.backgroundColor=color
        
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        layer.frame=self.view!.bounds
        view!.layer.addSublayer(layer)
        
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
