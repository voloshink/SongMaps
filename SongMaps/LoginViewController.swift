//
//  ViewController.swift
//  SongMaps
//
//  Created by Polecat on 11/11/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var backgroundView: FluidBackgroundView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradientLayer.frame = self.view.bounds
//        view.layer.insertSublayer(self.gradientLayer, at:0)
//
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            print("animating")
//            self.backgroundView.updateGradient()
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func lastFMTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.red, followed: UIColor.white)
    }
    
    @IBAction func spotifyTap(_ sender: Any) {
         self.backgroundView.updateGradient(with: UIColor.green, followed: UIColor.black)
    }
    
    @IBAction func manualTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.white, followed: UIColor.blue)
    }
    
}



