//
//  LayerClass.swift
//  testar
//
//  Created by diego on 6/5/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
class PartClass
{
    var levelController:LevelController?
    
    var layers=[PartLayerClass]()

    var duration:Int!
    var initialized:Bool=false
    
    init() {
        
    }
    
    public func setup(levelController:LevelController)
    {
        self.levelController=levelController
    }
}
