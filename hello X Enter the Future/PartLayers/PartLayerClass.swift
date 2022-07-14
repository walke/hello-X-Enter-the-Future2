//
//  LayerClass.swift
//  testar
//
//  Created by diego on 6/5/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class PartLayerClass
{
    var view:UIView?
    var levelController:LevelController?

    var duration:Int!
    var initialized:Bool=false
    
    init() {
        duration=0
    }
    
    public func setup(view:UIView,levelController:LevelController)
    {
        self.view=view
        self.levelController=levelController
    }
    
    func putUp()
    {
        initialized=true
    }
    
    func takeDown()
    {
        initialized=false
    }
}
