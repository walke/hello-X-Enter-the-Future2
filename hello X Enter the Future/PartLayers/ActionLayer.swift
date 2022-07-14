//
//  ActionLayer.swift
//  testar
//
//  Created by diego on 6/8/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit

class ActionLayer: PartLayerClass
{
    struct Action
    {
        var type:String?
        var action:String?
        var runOn:String
        var delay:CGFloat=0
        var data:Any?
        var progress:Int=0
        var capacity:Int=1
        var done:Bool=false
    }
    
    
    var actions:[Action]=[]
    
    init(duration:Int, actions: [Action])
    {
        //self.actions    = actions
        for action in actions
        {
            self.actions.append(action)
        }
        super.init()
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        levelController!.activeActionLayer = self

        
        for index in 0 ..< self.actions.count
        {
            if self.actions[index].runOn == "direct"
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.actions[index].delay))
                {
                    if !self.actions[index].done
                    {
                        self.levelController?.doAction(type: self.actions[index].type!, action: self.actions[index].action!, data: self.actions[index].data!)
                        self.actions[index].done=true
                        
                        
                    }
                    
                }
                //print(self.actions[index])
                
            }
            
        }
        
        super.putUp()
    }
    
    override func takeDown()
    {
        if !initialized{
            
            return
        }
        
        for index in 0 ..< self.actions.count
        {
            self.actions[index].done=true
        }
        
        super.takeDown()
    }
    
    func triggerCheck(trigger:String)
    {
        
        for index in 0 ..< self.actions.count
        {
            if !self.actions[index].done
            {
                if self.actions[index].runOn == trigger
                {
                    
                    //print(trigger)
                    self.actions[index].progress+=1
                    if self.actions[index].progress >= self.actions[index].capacity
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.actions[index].delay))
                        {
                            self.levelController?.doAction(type: self.actions[index].type!, action: self.actions[index].action!, data: self.actions[index].data!)
                            self.actions[index].done=true
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
    }
    
    
        
}
