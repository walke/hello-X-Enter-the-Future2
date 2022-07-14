//
//  PlayerLayer.swift
//  testar
//
//  Created by diego on 6/7/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class PlayerLayer: PartLayerClass
{
    var layer:AVPlayerLayer?
    
    var solidlayer:CALayer?
    
    
    var endAction:String?
    var skipAction = "skipvideo"
    var rewAction = "rewindvideo"
    var controllsAction = "showcontrolls"
    var showPlayerControlls:LevelController.ActionArea?
    var playerContinueAction:LevelController.ActionArea?
    var playerSkipAction:LevelController.ActionArea?
    var playerRewindAction:LevelController.ActionArea?
    
    var endTextLayer:CATextLayer?
    
    var timer:Timer
    var controllsShownAt:NSDate?
    var controlsShown=false
    
    
    init(duration:Int, local:Bool, path:String, endText:String, endAction:String)
    {
        layer           = AVPlayerLayer()
        endTextLayer    = CATextLayer()
        solidlayer      = CALayer()
        endTextLayer?.string=endText
        endTextLayer?.fontSize=24
        endTextLayer?.foregroundColor=UIColor.black.cgColor
        endTextLayer?.isWrapped=true
        endTextLayer?.alignmentMode = .center
        
        
        
        
        self.endAction       = endAction
        print(path)
        if local
        {
            let vpath = Bundle.main.path(forResource: "art.scnassets/films/"+path, ofType: "mp4")
            let videoURL = URL(fileURLWithPath: vpath!)
            let player = AVPlayer(url: videoURL)
            
            layer!.player=player
        }else
        {
            let videoURL = URL(string: path)
            let player = AVPlayer(url: videoURL!)
            
            layer!.player=player
        }
        
        /*let videoURL = URL(string: path)
        let player = AVPlayer(url: videoURL!)
        
        layer!.player=player*/
        timer=Timer()
        super.init()
        
        self.duration   = duration
        
    }
    
    override func putUp()
    {
        let mainBounds=view!.bounds
        layer!.frame=mainBounds
        
        
        
        solidlayer!.backgroundColor=CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        solidlayer!.frame.origin=CGPoint(x:0,y:0)
        solidlayer!.frame.size.width=mainBounds.width
        solidlayer!.frame.size.height=mainBounds.height
        solidlayer!.isHidden=false
        view!.layer.addSublayer(solidlayer!)
        
        view!.layer.addSublayer(layer!)
        
        endTextLayer!.frame.origin=CGPoint(x:mainBounds.width*0.1,y:mainBounds.height*0.2)
        endTextLayer!.frame.size.width=mainBounds.width*0.8
        endTextLayer!.frame.size.height=mainBounds.height*0.4
        endTextLayer!.isHidden=true
        
        view!.layer.addSublayer(endTextLayer!)
        
        levelController!.activePlayerLayer=self
        
        layer!.player!.play()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        

        let showControls = CALayer()
        showControls.frame.origin=CGPoint(x:0,y:0)
        showControls.frame.size.width=mainBounds.width
        showControls.frame.size.height=mainBounds.height-55
        showPlayerControlls=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: showControls, action: controllsAction,active:true)
        levelController!.addActionArea(actionArea:showPlayerControlls!)
        view!.layer.addSublayer(showControls)
        
        let skipButton = CALayer()
        let skipimage     = UIImage(named: "art.scnassets/images/skipbtn.png")?.cgImage
        skipButton.contents = skipimage
        skipButton.frame.origin=CGPoint(x:mainBounds.width-55,y:mainBounds.height-55)
        skipButton.frame.size.width=50
        skipButton.frame.size.height=50
        skipButton.isHidden=true
        
        playerSkipAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: skipButton, action: skipAction,active:false)
        levelController!.addActionArea(actionArea:playerSkipAction!)
        view!.layer.addSublayer(skipButton)
        
        let rewindButton = CALayer()
        let rewindimage     = UIImage(named: "art.scnassets/images/retbtn.png")?.cgImage
        rewindButton.contents = rewindimage
        rewindButton.frame.origin=CGPoint(x:5,y:mainBounds.height-55)
        rewindButton.frame.size.width=50
        rewindButton.frame.size.height=50
        rewindButton.isHidden=true
        
        playerRewindAction=LevelController.ActionArea(type:"layerimage",priority: 0, pointer: rewindButton, action: rewAction,active:false)
        levelController!.addActionArea(actionArea:playerRewindAction!)
        view!.layer.addSublayer(rewindButton)
        
        
        
        let continueButton = CATextLayer()
        continueButton.string="Neste"
        continueButton.fontSize=45
        continueButton.foregroundColor=UIColor.black.cgColor
        continueButton.alignmentMode=CATextLayerAlignmentMode.center
        continueButton.frame.origin=CGPoint(x:mainBounds.width/4,y:mainBounds.height-60)
        continueButton.frame.size.width=mainBounds.width/2
        continueButton.frame.size.height=50
        continueButton.borderColor=UIColor.black.cgColor
        continueButton.borderWidth=2
        continueButton.isHidden=true
        
        playerContinueAction=LevelController.ActionArea(type:"layer",priority: 0, pointer: continueButton, action: endAction!,active:false)
        levelController!.addActionArea(actionArea:playerContinueAction!)
        
        view!.layer.addSublayer(continueButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: layer!.player!.currentItem)
        
        super.putUp()
    }
    
    
    
    override func takeDown()
    {
        if !initialized{
            return
        }
        layer!.removeFromSuperlayer()
        endTextLayer!.removeFromSuperlayer()
        solidlayer!.removeFromSuperlayer()
        
        (playerContinueAction!.pointer as! CATextLayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:playerContinueAction!)
                
        (showPlayerControlls!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:showPlayerControlls!)
        (playerSkipAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:playerSkipAction!)
        (playerRewindAction!.pointer as! CALayer).removeFromSuperlayer()
        levelController!.removeActionArea(actionArea:playerRewindAction!)
        
        levelController!.activePlayerLayer=nil
        
        super.takeDown()
    }
    
    @objc func updateTime()
    {
        if controlsShown
        {
            let cnow=NSDate()
            let touchInterval=cnow.timeIntervalSince(controllsShownAt! as Date)

            if(!touchInterval.isLess(than: 3)){
                hideControlls()
            }
            
        }
    }
    
    func skipVideo()
    {
        let duration = layer?.player?.currentItem?.duration ?? CMTime()
        var currentTime=layer?.player?.currentTime() ?? CMTime()
        currentTime.value = currentTime.value + Int64(10000000000.0)
        //print(layer?.player?.currentItem?.duration)
        if(CMTimeCompare(currentTime, duration) == -1)
        {
            layer?.player?.seek(to: currentTime)
        }
        else
        {
            //layer?.player?.seek(to: duration)
        }
        
    }
    
    func rewindVideo()
    {
        //let duration = layer?.player?.currentItem?.duration ?? CMTime()
        var currentTime=layer?.player?.currentTime() ?? CMTime()
        currentTime.value = currentTime.value - Int64(10000000000.0)
        //print(layer?.player?.currentItem?.duration)
        
        layer?.player?.seek(to: currentTime)
        
        
    }
    
    func showControlls()
    {
        controllsShownAt=NSDate()
        controlsShown=true
        playerSkipAction?.active=true
        (playerSkipAction?.pointer as! CALayer).isHidden=false
        playerRewindAction?.active=true
        (playerRewindAction?.pointer as! CALayer).isHidden=false
    }
    
    func hideControlls()
    {
        controlsShown=false
        playerSkipAction?.active=false
        (playerSkipAction?.pointer as! CALayer).isHidden=true
        playerRewindAction?.active=false
        (playerRewindAction?.pointer as! CALayer).isHidden=true
    }
    
    @objc func playerDidFinishPlaying(note: NotificationCenter)
    {
        showPlayerControlls?.active=false
        solidlayer!.isHidden=false
        solidlayer!.backgroundColor=CGColor.init(red: 1.0, green: 0.97299844030000004, blue: 0.1611703038, alpha: 1.0)
        endTextLayer?.isHidden=false
        layer?.isHidden=true
        
        playerContinueAction?.active=true
        (playerContinueAction?.pointer as! CALayer).isHidden=false
        hideControlls()
        timer.invalidate()
    }
}
