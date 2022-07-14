//
//  ViewController.swift
//  hello X Enter the Future
//
//  Created by Tamara Sushko on 2021-04-21.
//

import UIKit
import MapKit
import CoreLocation
import SceneKit
import ARKit
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate{

    let levelController=LevelController()
    
    
    
    fileprivate let locationManager = CLLocationManager()
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0
        {
            
            let location = locations.last!
            //print("accuracy \(location.horizontalAccuracy)")
            if(location.horizontalAccuracy<70)
            {
                levelController.pushLocation(location:location)
            }

                //    let test_alert = UIAlertController(title: "test", message: "asd",preferredStyle: .alert)
                    
                //    test_alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                    
                //    self.present(test_alert,animated: true)

        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            //imageView.image = UIImage(named: const2)
        } else {
            print("Portrait")
            //imageView.image = UIImage(named: const)
        }
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UIDevice.current.orientation.isLandscape{
            print("AAAAA")
        }else{
            print("CCCCC")
        }
        print("BBBBB")
        
        levelController.setup()
        
        
        levelController.setupLevelController(view: view)
        levelController.delegate=self
        if(levelController.currentLevel == -1){
            DispatchQueue.main.async(){
               self.performSegue(withIdentifier: "showMenu", sender: self)
            }
        }else{
            levelController.play()
        }
        //levelController.play()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    
    public func currentPositionUpdater(state:Bool)
    {
        if(state){
            locationManager.startUpdatingLocation()
        }else{
            locationManager.stopUpdatingLocation()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(touches.count == 1)
        {
            for touch in touches
            {
                let touchPoint=touch.location(in:self.view)
                levelController.touch(point: touchPoint)
                
            }
            
            
        }
     
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            //print(time)
        guard let pov = levelController.arView!.pointOfView else { return }
        for index in 0 ..< levelController.activeARLayer!.activeAudio.count
        {
            let distance=levelController.activeARLayer?.Vector3Distance(v1:pov.position,v2:levelController.activeARLayer!.activeAudio[index].node.position)
            let volume = -0.5*distance!+1
            levelController.activeARLayer!.activeAudio[index].node.audioPlayers.forEach { player in
                if let audioNode = player.audioNode as? AVAudioMixing {
                    audioNode.volume = volume
                }
            }
            
            
            
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        print("STR RND")
        if anchor is ARPlaneAnchor
        {
            levelController.planeDetected(anchor: anchor as! ARPlaneAnchor)
            
 
            
            print("plane")
        }
        print("renderer")
        guard let imageAnchor = anchor as? ARImageAnchor else
        {
            return
        }
        
        levelController.markerScanned(anchor:imageAnchor)
        print("END RND")
        
        
        
    }
    
    @IBAction func unwindToAR(segue: UIStoryboardSegue){
        let defaults = UserDefaults.standard
        let level = defaults.string(forKey: "levelKey")
        //print(level)
        levelController.currentLevel = Int(level!) ?? 0
        levelController.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //TODO: pause all layers
        // Pause the view's session
     //   sceneView.session.pause()
        
    }


    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }


}

