//
//  ARLayer.swift
//  testar
//
//  Created by diego on 6/7/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit
import ARKit


class ARLayer: PartLayerClass
{
    let textField:CATextLayer
    
    
    var lastTouchTime:NSDate
    let standardAnimations=[
        "fadeIn":SCNAction.fadeIn(duration: 1),
        "fadeOut":SCNAction.fadeOut(duration: 1),
        "flip":SCNAction.sequence([SCNAction.move(by: SCNVector3(x: 0, y: 0.08, z: 0), duration: 1),SCNAction.group([SCNAction.move(by: SCNVector3(x: -0.16, y: 0.03, z: 0), duration: 1), SCNAction.rotateBy(x: 0, y: 0, z: 3, duration: 1)])]),
        "flipbig":SCNAction.sequence([SCNAction.move(by: SCNVector3(x: 0.0, y: 0.12, z: 0.05), duration: 1),SCNAction.group([SCNAction.move(by: SCNVector3(x: 0.0, y: 0.08, z: 0.32), duration: 1), SCNAction.rotateBy(x: 3, y: 0, z: 0, duration: 1)])]),
        "tap":SCNAction.sequence([SCNAction.move(by: SCNVector3(x: 0, y: -0.02, z: 0), duration: 0.2),SCNAction.move(by: SCNVector3(x: 0, y: 0.02, z: 0), duration: 0.2)]),
    ]
    
    let spores:SCNParticleSystem
    let sporeNode:SCNNode
    
    struct ARActiveElement
    {
        var title:String
        var pointer:Any
        var type:String
        var action:String
        var actionDelay:CGFloat?
        var actionData:Any?
        var active:Bool
        var position:SCNVector3?
        var rotation:SCNVector4?
        var scale:SCNVector3?
        var actionAnimation:String?
        var actionParticles:String?
        var inDuration:CGFloat?
        var done:Bool=false
        var progress:Int?
    }
    
    struct ARParticleElement
    {
        var title:String
        var pointer:Any?
        var birthRate:Int
        var position:SCNVector3
        var parent:String?
        var particleSize:CGFloat
        var color:CGColor
    }
    
    struct ARAudioElement{
        var node:SCNNode
        var source:SCNAudioSource
    }
    
    struct ARForceElement
    {
        var title:String
        var position:SCNVector3
        var strength:CGFloat=0
        var type:String
        var minDistance:CGFloat=0
    }
    
    var baseScene:SCNScene?
    
    
    
    var originType:String?
    var origin:String?
    var activeElements:[ARActiveElement]=[]
    var preActiveElements:[ARActiveElement]
    
    var activeParticles:[ARParticleElement]=[]
    var preActiveParticles:[ARParticleElement]
    
    var activeAudio:[ARAudioElement]=[]
    
    
    
    var viewSnap:SCNNode
    
    var scenePlaced:Bool=false
    var layer:ARSCNView?
    
    init(duration:Int,originType:String,origin:String,baseScene:String,activeElements:[ARActiveElement],activeParticles:[ARParticleElement])
    {
        self.baseScene      = SCNScene(named: "art.scnassets/scenes/"+baseScene)!
        
        
        
        print(self.baseScene)
        self.originType     = originType
        self.origin         = origin
        self.preActiveElements = activeElements
        self.preActiveParticles = activeParticles
        
       // layer           = ARSCNView()
        
       // layer!.delegate=levelController!.delegate
        
        self.spores             = SCNParticleSystem()
        self.spores.birthRate   = 100
        self.spores.particleSize=0.001
        self.spores.particleLifeSpan=4
        self.spores.particleColor = .yellow
        self.spores.particleVelocity=0
        self.spores.birthDirection = .random
        self.spores.dampingFactor = 5
        self.spores.isAffectedByPhysicsFields=true
        self.spores.loops=false
        self.spores.emissionDuration=0.1
        self.spores.isAffectedByGravity=true
        self.spores.particleMass=10
        
        
        let floor:SCNNode? = self.baseScene!.rootNode.childNode(withName: "floor", recursively: true)
        //print(self.baseScene!.rootNode)
        if floor != nil
        {
            self.spores.colliderNodes=[floor!]
        }
       // print(self.spores.colliderNodes!)
        //partss.blendMode = .additive
        
        self.sporeNode=SCNNode()
        self.sporeNode.renderingOrder=1
        
        self.sporeNode.addParticleSystem(self.spores)
        
        self.viewSnap = SCNNode()
        self.viewSnap.position=SCNVector3Make(0,0,-0.3)
        self.viewSnap.rotation=SCNVector4Make(1,0,0,Float(Double.pi/2))
        
        lastTouchTime=NSDate()

        
        textField=CATextLayer()
        
        super.init()
        
        
        
        self.duration   = duration
    }
    
    override func putUp()
    {
        if levelController!.arView == nil
        {
            levelController!.arView = ARSCNView()
        }
        layer=levelController!.arView!
        

        
        layer!.pointOfView!.addChildNode(self.viewSnap)
        self.viewSnap.position=SCNVector3Make(0,0,-0.2)
        self.viewSnap.rotation=SCNVector4Make(1,0,0,Float(Double.pi/2))
        
        layer?.antialiasingMode = .none
        //layer?.showsStatistics = true
        
        layer!.delegate=levelController!.delegate
        
        levelController!.activeARLayer=self
        
        layer!.frame=self.view!.bounds
        view!.addSubview(layer!)
        
        textField.string=""
        textField.fontSize=45
        textField.foregroundColor=UIColor.white.cgColor
        textField.alignmentMode=CATextLayerAlignmentMode.center
        textField.frame.origin=CGPoint(x:0,y:layer!.frame.height-120)
        textField.frame.size.width=layer!.frame.width
        textField.frame.size.height=50
        textField.borderColor=UIColor.white.cgColor
        textField.borderWidth=2
        textField.isHidden=true
        
        view!.layer.addSublayer(textField)
        
        let configuration = ARWorldTrackingConfiguration()
        
        guard let refImage = ARReferenceImage.referenceImages(inGroupNamed: "markers", bundle: nil) else
        {
            fatalError("could not load tracking images")
        }
        
        configuration.detectionImages = refImage
        configuration.planeDetection = [.horizontal]
        layer!.session.run(configuration, options:[.resetTracking, .removeExistingAnchors])
        //layer!.session.run(configuration)
        
        
        
        layer!.scene = baseScene!
        
        layer!.scene.rootNode.isHidden=true
        
        layer!.autoenablesDefaultLighting=true
        layer!.automaticallyUpdatesLighting=true
        
        
        
        if !scenePlaced
        {
            if originType == "POI"
            {
                
                    
                //layer!.scene = baseScene!
                //layer!.scene.background=SCNMaterialProperty.
                //SCNParticleSystem(named: "", inDirectory: <#T##String?#>)
                /*let partss=SCNParticleSystem()
                partss.birthRate=100
                partss.particleSize=2.45
                partss.particleLifeSpan=2
                partss.particleColor = .yellow
                print("pcount")
                print(partss)*/
                
                layer!.scene.rootNode.isHidden=false
                layer!.scene.rootNode.opacity=0
                //layer!.scene.rootNode.childNodes[0].addParticleSystem(partss)
                layer!.scene.rootNode.position=SCNVector3Make(0,-1,-2)
                //layer!.scene.rootNode.childNodes[0].position=SCNVector3Make(0,-1,-2)
                //layer!.session.setWorldOrigin()
                layer!.scene.rootNode.runAction(standardAnimations["fadeIn"]!)
                //layer!.session.setWorldOrigin(relativeTransform: inFrontOfCamera())
                //layer!.scene.rootNode.childNodes[0].position = SCNVector3(0,0,-2)
                scenePlaced = true
                
                
            }
        }
        //layer!.scene.rootNode.addChildNode(baseScene!)
        //let circleNode = createSphereNode(with: 0.2, color: .blue)
          
          //circleNode.position = SCNVector3(0,0,-1)
          
          // Set the scene to the view
        //  sceneView.scene = scene
          
          //arView!.scene.rootNode.addChildNode(circleNode)
        
        
         
        /* for activeElement in content.activeElements
         {
             
         }
         */
         
        super.putUp()
        
    }
    
    override func takeDown()
    {
        
        if !initialized{
            
            return
        }
        
        layer!.scene.rootNode.enumerateChildNodes{(node,stop) in
            node.removeFromParentNode()
            node.removeAllAudioPlayers()
        }
        
        layer!.session.pause()
        
        
        activeElements=[]
        
        layer!.removeFromSuperview()
        textField.removeFromSuperlayer()
        
        levelController!.arView=nil
        
        super.takeDown()
    }
    
    func planeDetected(anchor:ARPlaneAnchor)
    {
        if !scenePlaced
        {
            if originType == "ground"
            {
                
                    
                //layer!.scene = baseScene!
                layer!.scene.rootNode.isHidden = false
                layer!.scene.rootNode.opacity=0
                layer!.scene.rootNode.runAction(standardAnimations["fadeIn"]!)
                layer!.session.setWorldOrigin(relativeTransform: anchor.transform)
                //layer!.scene.rootNode.childNodes[0].position = SCNVector3(0,0,-2)
                scenePlaced = true
                
                for activeElement in self.preActiveElements
                {
                    addActiveElement(element:activeElement)
                }
                
            }
        }
    }
    
    func markerScanned(anchor:ARImageAnchor)
    {
        //print(anchor.debugDescription)
        
        if !scenePlaced
        {
            if originType == "marker"
            {
                if origin == anchor.referenceImage.name
                {
                    
                    //layer!.scene = baseScene!
                    layer!.scene.rootNode.isHidden=false
                    layer!.scene.rootNode.opacity=0
                    layer!.scene.rootNode.runAction(standardAnimations["fadeIn"]!)
                    layer!.session.setWorldOrigin(relativeTransform: anchor.transform)
                    //layer!.scene.rootNode.childNodes[0].position = SCNVector3(0,0,-2)
                    scenePlaced = true
                    
                    for activeElement in self.preActiveElements
                    {
                        
                        addActiveElement(element:activeElement)
                    }
                    
                }
                
            }
        }
        
        for activeElement in activeElements
        {
            //print(anchor.referenceImage.name)
            if activeElement.type == "marker" && (activeElement.pointer as! String) == anchor.referenceImage.name
            {
                
                //wait(2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                {
                    self.doARAction(action:activeElement.action)
                }
                
            }
        }
    }
    
    func doARAction(action:String)
    {
        //print(action)
        switch action {
        case "nextPart":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                self.levelController?.doAction(type:"layer",action: "nextPart",data:[])
            }
            //levelController?.doAction(type:"layer",action: "nextPart",data:[])
        default:
            levelController?.doAction(type:"null",action: action,data:[])
            //print("invalid action")
        }
    }
    
    /*func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode
    {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }*/
    //MARK: - AR ELEMENT MANIPULATION METHODS
    func addForceElement(element:ARForceElement)
    {
        let force:SCNPhysicsField
        switch element.type {
        case "radial":
            force=SCNPhysicsField.radialGravity()
        case "vortex":
            force=SCNPhysicsField.vortex()
        case "turbulence":
            force=SCNPhysicsField.turbulenceField(smoothness: 0.7, animationSpeed: 0.9)
        case "drag":
            force=SCNPhysicsField.drag()
        default:
            return
        }
        
        force.strength=0
        force.minimumDistance=element.minDistance

        
        
        
        let fieldNode=SCNNode()
        fieldNode.physicsField=force
        fieldNode.position=element.position
        
        let anim=SCNAction.customAction(duration: 1) { (node, elapsedTime) in
            let perc = elapsedTime / CGFloat(self.duration)
            node.physicsField?.strength = perc * element.strength
        }
        
        
        baseScene!.rootNode.addChildNode(fieldNode)
        
        fieldNode.runAction(anim)
    }
    
    func addParticleElement(element:ARParticleElement)
    {
        let partss=SCNParticleSystem()
        partss.birthRate=CGFloat(element.birthRate)
        partss.particleSize=element.particleSize
        partss.particleLifeSpan=8
        partss.particleColor = UIColor(cgColor:element.color)
        partss.particleVelocity=1
        partss.birthDirection = .random
        partss.dampingFactor = 1
        partss.isAffectedByPhysicsFields=true
        partss.blendMode = .alpha
        partss.isBlackPassEnabled=true
        
        //partss.blendMode = .additive
        
        let particleNode=SCNNode()
        
        particleNode.addParticleSystem(partss)
        particleNode.position=element.position
        
        //print(partss)
        var parentNode=baseScene!.rootNode
        if element.parent != nil
        {
            for activeElement in activeElements
            {
                if activeElement.title == element.parent
                {
                    var geometry:SCNGeometry? = (activeElement.pointer as! SCNNode).geometry
                    
                    if geometry == nil
                    {
                        for childnode in (activeElement.pointer as! SCNNode).childNodes
                        {
                            geometry = childnode.geometry
                            particleNode.transform=childnode.transform
                            
                        }
                    }
                    
                    if geometry != nil
                    {
                        partss.emitterShape = .some(geometry!)
                        
                    }
                    
                    //print(geometry)
                    parentNode=activeElement.pointer as! SCNNode
                    break
                }
            }
        }
        particleNode.renderingOrder = 1
        parentNode.addChildNode(particleNode)
        
        activeParticles.append(ARParticleElement(
            title: element.title,
            pointer: particleNode,
            birthRate: element.birthRate,
            position: element.position,
            particleSize: element.particleSize,
            color: element.color)
        )
    }
    
    func addActiveElement(element:ARActiveElement)
    {
        switch element.type {
        case "static":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                print (obj)
                //let obj=levelController!.objects[(element.pointer as! String)]
                print("OBJ"+element.title)
                print(obj)
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    //node.removeFromParentNode()
                    self.baseScene!.rootNode.addChildNode(node)
                    //baseScene!.rootNode.childNodes.last!.geometry
                    self.baseScene!.rootNode.childNodes.last!.position=element.position!
                    if element.rotation != nil
                    {
                        self.baseScene!.rootNode.childNodes.last!.rotation=element.rotation!
                    }
                    
                    self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                    self.baseScene!.rootNode.childNodes.last!.opacity=0
                    self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                    self.activeElements.append(ARActiveElement(
                        title: element.title,
                        pointer: node,
                        type: element.type,
                        action: element.action,
                        actionDelay: element.actionDelay,
                        active: element.active,
                        position: element.position,
                        rotation: element.rotation,
                        scale: element.scale))
                }
            }
        case "touch":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                print (obj)
                //let obj=levelController!.objects[(element.pointer as! String)]
                //let node=obj.rootNode
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    self.baseScene!.rootNode.addChildNode(node)
                    
                    self.baseScene!.rootNode.childNodes.last!.position=element.position!
                    self.baseScene!.rootNode.childNodes.last!.rotation=element.rotation!
                    self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                    self.baseScene!.rootNode.childNodes.last!.opacity=0
                    self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                    self.activeElements.append(ARActiveElement(title:element.title,
                                                          pointer: node,
                                                          type: element.type,
                                                          action: element.action,
                                                          actionDelay: element.actionDelay,
                                                          active: element.active,
                                                          position: element.position,
                                                          rotation: element.rotation,
                                                          scale: element.scale,
                                                          actionAnimation:element.actionAnimation))
                }
            }
            
            
            
        case "touch sequence":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                //let obj=levelController!.objects[(element.pointer as! String)]
                
                let sequenceGroup=SCNNode()
                
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    sequenceGroup.addChildNode(node)
                }
                
                self.baseScene!.rootNode.addChildNode(sequenceGroup)
                
                self.baseScene!.rootNode.childNodes.last!.position=element.position!
                self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                self.baseScene!.rootNode.childNodes.last!.opacity=0
                self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                self.activeElements.append(ARActiveElement(title:element.title,
                                                      pointer: sequenceGroup,
                                                      type: element.type,
                                                      action: element.action,
                                                      actionDelay: element.actionDelay,
                                                      actionData: element.actionData,
                                                      active: element.active,
                                                      position: element.position,
                                                      rotation: element.rotation,
                                                      scale: element.scale,
                                                      actionAnimation:element.actionAnimation,
                                                      actionParticles:element.actionParticles,
                                                      progress: 0))
            }
            
            
        case "card":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                //let obj=levelController!.objects[(element.pointer as! String)]
                //let node=obj.rootNode
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    self.baseScene!.rootNode.addChildNode(node)
                    
                    self.baseScene!.rootNode.childNodes.last!.position=element.position!
                    self.baseScene!.rootNode.childNodes.last!.rotation=element.rotation!
                    self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                    self.baseScene!.rootNode.childNodes.last!.opacity=0
                    self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                    self.activeElements.append(ARActiveElement(title:element.title,
                                                          pointer: node,
                                                          type: element.type,
                                                          action: element.action,
                                                          actionDelay: element.actionDelay,
                                                          active: element.active,
                                                          position: element.position,
                                                          rotation: element.rotation,
                                                          scale: element.scale,
                                                          actionAnimation:element.actionAnimation,
                                                          progress: 0))
                }
            }
            
            
        case "dragndrop":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                //let obj=levelController!.objects[(element.pointer as! String)]
                
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    self.baseScene!.rootNode.addChildNode(node)
                    
                    self.baseScene!.rootNode.childNodes.last!.position=element.position!
                    self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                    self.baseScene!.rootNode.childNodes.last!.opacity=0
                    self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                    self.activeElements.append(ARActiveElement(title:element.title,
                                                          pointer: node,
                                                          type: element.type,
                                                          action: element.action,
                                                          actionDelay: element.actionDelay,
                                                          actionData: element.actionData,
                                                          active: element.active,
                                                          position: element.position,
                                                          rotation: element.rotation,
                                                          scale: element.scale,
                                                          actionAnimation:element.actionAnimation))
                }
            }
            
        case "dropzone":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                //let obj=levelController!.objects[(element.pointer as! String)]
                
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    self.baseScene!.rootNode.addChildNode(node)
                    
                    self.baseScene!.rootNode.childNodes.last!.position=element.position!
                    self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                    self.baseScene!.rootNode.childNodes.last!.opacity=0
                    self.baseScene!.rootNode.childNodes.last!.runAction(self.standardAnimations["fadeIn"]!)
                    self.activeElements.append(ARActiveElement(title:element.title,
                                                          pointer: node,
                                                          type: element.type,
                                                          action: element.action,
                                                          actionDelay: element.actionDelay,
                                                          actionData: element.actionData,
                                                          active: element.active,
                                                          position: element.position,
                                                          rotation: element.rotation,
                                                          scale: element.scale,
                                                          actionAnimation:element.actionAnimation))
                }
            }
            
        case "sequence":
            DispatchQueue.main.async {
                let obj=SCNScene(named:"art.scnassets/objects/"+(element.pointer as! String))!
                //let obj=levelController!.objects[(element.pointer as! String)]
                
                let sequenceGroup=SCNNode()
                
                for node in obj.rootNode.childNodes as [SCNNode]
                {
                    sequenceGroup.addChildNode(node)
                }
                
                self.baseScene!.rootNode.addChildNode(sequenceGroup)
                
                self.baseScene!.rootNode.childNodes.last!.position=element.position!
                self.baseScene!.rootNode.childNodes.last!.scale=element.scale!
                var nodendx=0
                var partDuration:CGFloat=1
                var fadeDuraton:CGFloat=0.25
                if element.inDuration != nil
                {
                    partDuration=element.inDuration! / CGFloat(self.baseScene!.rootNode.childNodes.last!.childNodes.count)
                    fadeDuraton=partDuration/4
                }
                for node in self.baseScene!.rootNode.childNodes.last!.childNodes
                {
                    node.opacity=0
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(CGFloat(nodendx)*(partDuration-(fadeDuraton))))
                    {
                        node.runAction(SCNAction.fadeIn(duration: Double(fadeDuraton)))
                    }
                    if (nodendx+1) < self.baseScene!.rootNode.childNodes.last!.childNodes.count
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double((CGFloat(nodendx+1))*(partDuration-fadeDuraton)+fadeDuraton))
                        {
                            node.runAction(SCNAction.fadeOut(duration: Double(fadeDuraton)))
                        }
                    }
                    
                    
                    nodendx += 1
                }
                
                
                self.activeElements.append(ARActiveElement(title:element.title,
                                                      pointer: sequenceGroup,
                                                      type: element.type,
                                                      action: element.action,
                                                      actionDelay: element.actionDelay,
                                                      actionData: element.actionData,
                                                      active: element.active,
                                                      position: element.position,
                                                      rotation: element.rotation,
                                                      scale: element.scale,
                                                      actionAnimation:element.actionAnimation,
                                                      progress: 0))
            }
            
        case "marker":
            activeElements.append(ARActiveElement(
                title:element.title,
                pointer: element.pointer,
                type: element.type,
                action: element.action,
                actionDelay: element.actionDelay,
                actionData: element.actionData,
                active: element.active,
                position: element.position,
                rotation: element.rotation,
                scale: element.scale,
                actionAnimation:element.actionAnimation))
        case "music":
            
            DispatchQueue.main.async {
                self.activeAudio.append(ARAudioElement(
                    node:SCNNode(),
                    source: SCNAudioSource(fileNamed: "art.scnassets/music/"+(element.pointer as! String))!)
                )
                
                
                self.baseScene!.rootNode.addChildNode(self.activeAudio.last!.node)
                self.activeAudio.last!.node.position=element.position!
                //let audio = SCNAudioSource(fileNamed: "art.scnassets/music/"+(element.pointer as! String))! // add audio file
                self.activeAudio.last!.source.loops = true
                //activeAudio.last!.source.volume = 1.0
                //activeAudio.last!.source.rate = 1.2
                //activeAudio.last!.source.reverbBlend = 40
                
                self.activeAudio.last!.source.isPositional = true
                self.activeAudio.last!.source.shouldStream = false
                
                let player = SCNAudioPlayer(source: self.activeAudio.last!.source)
                self.activeAudio.last!.node.addAudioPlayer(player)
                self.activeAudio.last!.source.load()
                
                //layer!.audioEnvironmentNode.listenerAngularOrientation: Float { get set }
                //layer!.audioEnvironmentNode.distanceAttenuationParameters.rolloffFactor: Float { get set }
                //layer!.audioEnvironmentNode.distanceAttenuationParameters.maximumDistance = 1
                //layer!.audioEnvironmentNode.distanceAttenuationParameters.referenceDistance = 0.1
                //layer!.audioEnvironmentNode.renderingAlgorithm = .sphericalHead
                
                
                print("AUDIO")
                //print(newNode.audioPlayers)
                //baseScene!.rootNode.runAction(SCNAction.playAudio(audioSource, waitForCompletion: false))
                
                
                
                self.activeElements.append(ARActiveElement(
                    title:element.title,
                    pointer: player,
                    type: element.type,
                    action: element.action,
                    actionDelay: element.actionDelay,
                    actionData: element.actionData,
                    active: element.active,
                    position: element.position,
                    rotation: element.rotation,
                    scale: element.scale,
                    actionAnimation:element.actionAnimation))
            }
            
        default:
            print("invalid element type")
        }
    }
    
    func removeActiveElements(elements:[String])
    {
        for element in elements
        {
            for index in 0 ..< activeElements.count
            {
                if element == activeElements[index].title
                {
                    (activeElements[index].pointer as! SCNNode).runAction(standardAnimations["fadeOut"]!)
                    //(activeElements[index].pointer as! SCNNode).isHidden=true
                    
                    
                }
            }
            
            for index in 0 ..< activeElements.count
            {
                if element == activeElements[index].title && activeElements[index].type == "music"
                {
                    baseScene!.rootNode.removeAudioPlayer((activeElements[index].pointer as! SCNAudioPlayer))
                    //print((activeElements[index].pointer as! SCNNode).audioPlayers)
                    //(activeElements[index].pointer as! SCNNode).removeAllAudioPlayers()
                    //(activeElements[index].pointer as! SCNNode).isHidden=true
                }
            }
            
            for index in 0 ..< activeParticles.count
            {
                if element == activeParticles[index].title
                {
                    //print("removing particles: "+element)
                    (activeParticles[index].pointer as! SCNNode).particleSystems![0].birthRate=0
                    //(activeElements[index].pointer as! SCNNode).runAction(standardAnimations["fadeOut"]!)
                    //(activeElements[index].pointer as! SCNNode).isHidden=true
                }
            }
        }
    }
    
    func actionParticles(node:SCNNode,element:ARActiveElement)
    {
        
        var partss:SCNParticleSystem? = nil
        var partnode:SCNNode? = nil
        switch element.actionParticles
        {
            case "spores":
                partss=self.spores
                partnode=self.sporeNode
            default:
                return
        }
        node.addChildNode( partnode! )
        var geometry:SCNGeometry? = node.geometry
        //sporeNode.transform=result.node.transform
        //sporeNode.position=result.node.position
        if geometry == nil
        {
            for childnode in node.childNodes
            {
                geometry = childnode.geometry
                //sporeNode.transform=childnode.transform
                //sporeNode.position=childnode.position
            }
        }
        
        if geometry != nil
        {
            partss!.emitterShape = .some(geometry!)
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            partnode!.removeFromParentNode()
        }
        
    }
    
    func touch(point:CGPoint)
    {
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: false]
        let hitTestResults = layer!.hitTest(point, options: hitTestOptions)
        
        let touchTime=NSDate()
        let touchInterval=touchTime.timeIntervalSince(lastTouchTime as Date)

        if(touchInterval.isLess(than: 0.05)){
            return;
        }
        
        lastTouchTime=NSDate()
        for result in hitTestResults
        {
            
            
            
            
            for index in 0 ..< activeElements.count
            {
                //print(result.node.parent)
                if !activeElements[index].done || activeElements[index].type == "card"
                {
                    
                    //print(activeElements[index])
                    switch activeElements[index].type {
                    case "touch":
                        
                        if activeElements[index].pointer as! SCNNode == result.node
                        {
                            //print("touch")
                            if activeElements[index].actionAnimation != nil
                            {
                                (activeElements[index].pointer as! SCNNode).runAction(standardAnimations[activeElements[index].actionAnimation!]!)
                            }
                            doARAction(action: activeElements[index].action)
                            activeElements[index].done=true
                        }
                        
                    case "touch sequence":
                        if (activeElements[index].pointer as! SCNNode) == result.node.parent
                        {
                            
                            //print( result.node.name! )
                            if activeElements[index].actionParticles != nil
                            {
                                //print("particlesact")
                                actionParticles(node:result.node,element:activeElements[index])
                            }
                            
                            if activeElements[index].actionAnimation != nil
                            {
                                result.node.runAction(standardAnimations[activeElements[index].actionAnimation!]!)
                                
                            }
                            
                            //print(activeElements[index].actionData as! [String:Any?])
                            let seqKeys=(activeElements[index].actionData as! [String:Any?])["keys"] as! [Int:Any?]
                            let seqRef=(activeElements[index].actionData as! [String:Any?])["sequence"] as! [Int]
                            var seqEnt=(activeElements[index].actionData as! [String:Any?])["enteredSequence"] as! [Int]
                            for index in 0 ..< seqKeys.count
                            {
                                let seqKey=seqKeys[index] as! [String:String]
                                if seqKey["model"] == result.node.name!
                                {
                                    seqEnt.append(index)
                                }
                            }
                            activeElements[index].actionData=["keys":seqKeys,"sequence":seqRef,"enteredSequence":seqEnt]
                            seqEnt=(activeElements[index].actionData as! [String:Any?])["enteredSequence"] as! [Int]
                            //print(seqEnt)
                            
                            var wrongPass=false
                            if seqEnt.count==seqRef.count {
                                let totSymbols=seqRef.count
                                var correctSymbols=0
                                for index in 0 ..< seqEnt.count
                                {
                                    if seqEnt[index] == seqRef[index]
                                    {
                                        correctSymbols += 1
                                    }
                                }
                                if totSymbols == correctSymbols
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.1))
                                    {
                                        self.textField.foregroundColor=UIColor.green.cgColor
                                    }
                                    
                                    doARAction(action: activeElements[index].action)
                                    activeElements[index].done=true
                                }
                                else {
                                    seqEnt=[]
                                    activeElements[index].actionData=["keys":seqKeys,"sequence":seqRef,"enteredSequence":seqEnt]
                                    wrongPass=true
                                }
                            }
                            if seqEnt.count > 0
                            {
                                textField.isHidden=false
                                textField.foregroundColor=UIColor.white.cgColor
                                var seqString="";
                                for index in 0 ..< seqEnt.count
                                {
                                    seqString = seqString + (seqKeys[seqEnt[index]] as! [String:String])["display"]!
                                }
                                textField.string=seqString
                            }else{
                                //textField.isHidden=true
                            }
                            
                            if wrongPass
                            {
                                textField.foregroundColor=UIColor.red.cgColor
                                textField.string="Prøv igjen!"
                            }
                            
                            /*if (activeElements[index].actionData as! [Int:String])[activeElements[index].progress!] == result.node.name!
                            {
                                activeElements[index].progress! += 1
                            }
                            else if (activeElements[index].actionData as! [Int:String])[0] == result.node.name!
                            {
                                activeElements[index].progress!=1
                            }
                            else
                            {
                                //print("WRONG"+(activeElements[index].actionData as! [Int:String])[activeElements[index].progress!]! + "-" + result.node.name!)
                                activeElements[index].progress! = 0
                            }*/
                            
                           // print(activeElements[index].progress)
                            /*if activeElements[index].progress! >= (activeElements[index].actionData as! [Int:String]).count
                            {
                                doARAction(action: activeElements[index].action)
                                activeElements[index].done=true
                            }*/
                            
                            //print("NNNNN\(result.node.name)")
                            return
                        }
                    case "card":
                        
                        if activeElements[index].pointer as! SCNNode == result.node
                        {
                            
                            if activeElements[index].actionAnimation != nil
                            {
                                if activeElements[index].actionAnimation == "card"
                                {
                                    switch activeElements[index].progress {
                                    case 0:
                                       
                                        
                                        
                                        (activeElements[index].pointer as! SCNNode).removeFromParentNode()
                                        (activeElements[index].pointer as! SCNNode).position=SCNVector3Make(0,0,-0.2)
                                        (activeElements[index].pointer as! SCNNode).rotation=SCNVector4Make(1,0,0,Float(Double.pi/2))
                                        layer!.pointOfView!.addChildNode((activeElements[index].pointer as! SCNNode))
                                        
                                        //(activeElements[index].pointer as! SCNNode).constraints=[constraintLA]
                                        //(activeElements[index].pointer as! SCNNode).runAction(liftAnimation)
                                        activeElements[index].progress! += 1
                                    case 1:
                                        let turnAnimation=SCNAction.rotate(by: CGFloat(Double.pi), around:  SCNVector3Make(0,1,0), duration: 0.5)
                                        (activeElements[index].pointer as! SCNNode).runAction(turnAnimation)
                                        activeElements[index].progress! += 1
                                    default:
                                        (activeElements[index].pointer as! SCNNode).removeFromParentNode()
                                        layer!.scene.rootNode.addChildNode((activeElements[index].pointer as! SCNNode))
                                        (activeElements[index].pointer as! SCNNode).position=activeElements[index].position!
                                        (activeElements[index].pointer as! SCNNode).rotation=activeElements[index].rotation!
                                        activeElements[index].progress! = 0
                                        if !activeElements[index].done
                                        {
                                            doARAction(action: activeElements[index].action)
                                            activeElements[index].done=true
                                        }
                                        
                                        
                                        break
                                    }
                                }
                                
                            }
                            //doARAction(action: activeElements[index].action)
                            //activeElements[index].done=true
                        }
                    case "dragndrop":
                        
                        if activeElements[index].pointer as! SCNNode == result.node
                        {
                            var delay:CGFloat=0
                            if activeElements[index].actionDelay != nil
                            {
                                delay=activeElements[index].actionDelay!
                            }
                            if activeElements[index].actionAnimation != nil
                            {
                                var dropPosition=SCNVector3(0,0,0)
                                var dropElement:ARActiveElement?=nil
                                for element in activeElements
                                {
                                    if element.action == activeElements[index].actionData as! String
                                    {
                                        dropPosition=element.position!
                                        dropElement=element
                                    }
                                }
                                
                                //print(layer!.pointOfView!.position)
                                //let dragndropAnimation=SCNAction.group([SCNAction.move(to: dropPosition, duration: Double(delay)), SCNAction.rotateBy(x: 0, y: 0, z: 3, duration: Double(delay))])
                                
                                let toCamera=SCNAction.customAction(duration: 2) { (node, elapsed) in
                                    let percentage = elapsed / CGFloat(self.duration)
                                    let oldposx=node.position.x
                                    let oldposy=node.position.y
                                    let oldposz=node.position.z
                                    
                                    let dx=self.viewSnap.worldPosition.x-oldposx
                                    let dy=self.viewSnap.worldPosition.y-oldposy
                                    let dz=self.viewSnap.worldPosition.z-oldposz
                                    //let dx=self.layer!.pointOfView!.position.x-oldposx
                                    //let dy=self.layer!.pointOfView!.position.y-oldposy
                                    //let dz=self.layer!.pointOfView!.position.z-oldposz
                                    let X=oldposx+dx*Float(percentage)
                                    let Y=oldposy+dy*Float(percentage)
                                    let Z=oldposz+dz*Float(percentage)
                                    //let zd=percentage * CGFloat(self.layer!.pointOfView!.position.x)
                                    node.position=SCNVector3(x: X, y: Y, z: Z)
                                    if(self.Vector3Distance(v1:node.position,v2:dropPosition)<0.11){
                                        node.removeAction(forKey: "toCamera")
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay))
                                        {
                                            if(!self.activeElements[index].done)
                                            {
                                                self.doARAction(action: self.activeElements[index].action)
                                                    self.activeElements[index].done=true
                                                
                                                if dropElement != nil
                                                {
                                                    self.doARAction(action: dropElement!.action)
                                                    dropElement!.done=true
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                //let dragndropAnimation=SCNAction.group([SCNAction.move(to: layer!.pointOfView!.position, duration: Double(delay)), SCNAction.rotateBy(x: 0, y: 0, z: 3, duration: Double(delay))])
                                let repeatForever = SCNAction.repeatForever(toCamera)
                                //(activeElements[index].pointer as! SCNNode).runAction(dragndropAnimation)
                                (activeElements[index].pointer as! SCNNode).runAction(repeatForever, forKey: "toCamera")
                                //print(delay)
                                
                                /*DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay))
                                {
                                    self.doARAction(action: self.activeElements[index].action)
                                        self.activeElements[index].done=true
                                    
                                    if dropElement != nil
                                    {
                                        self.doARAction(action: dropElement!.action)
                                        dropElement!.done=true
                                    }
                                }*/
                                
                                
                                
                                
                            }
                        }
                    
                    default:
                        break
                       //print("invalid interaction type")
                    }
                    
                    
                    
                }
                
                
            }
        }
    }
    
    func Vector3Multiply (v: SCNVector3,s:Float) -> SCNVector3
    {
        return SCNVector3(v.x * s, v.y * s, v.z * s)
    }
    
    func Vector3Add (v1: SCNVector3,v2:SCNVector3) -> SCNVector3
    {
        return SCNVector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
    }
    
    func inFrontOfCamera() -> SCNVector3
    {
        //print(layer!.pointOfView!.position)
        //print(layer!.pointOfView!.worldFront)
        //layer!.pointOfView!.
        return layer!.pointOfView!.position
        
    }
    
    func Vector3Distance(v1: SCNVector3, v2: SCNVector3 ) -> Float
    {
        let distance = SCNVector3(
            v2.x - v1.x,
            v2.y - v1.y,
            v2.z - v1.z
        )
        return sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
    }
    
}
