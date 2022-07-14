//
//  MenuViewController.swift
//  HelloXAR
//
//  Created by Jegor Sushko on 2021-04-13.
//

import Foundation
import UIKit

class MenuViewController: UIViewController{
    
    weak var mainViewController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("asdasdasd")
    }
    
    @IBAction func playLevel1(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "levelKey")
        self.performSegue(withIdentifier: "unwindToAR", sender: self)
    }
    
    @IBAction func playLevel2(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(1, forKey: "levelKey")
        self.performSegue(withIdentifier: "unwindToAR", sender: self)
    }
    
    @IBAction func playLevel3(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.set(2, forKey: "levelKey")
        self.performSegue(withIdentifier: "unwindToAR", sender: self)
    }
    
}
