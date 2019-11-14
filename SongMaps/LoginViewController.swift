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
    @IBOutlet weak var lastFMButton: RoundedButton!
    @IBOutlet weak var spotifyButton: RoundedButton!
    @IBOutlet weak var manualButton: RoundedButton!
    
    let spotify = Spotify()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func spotifyAuthResponse(code: String, state: String, error: String?) {
        if let error = error {
            // handle error
            // reset gradient
            return
        }

        spotify.authorizationResponse(code: code, state: state, progress: { progress in
            print("Progress " + String(progress))
            }, completion: { artists in
            print("Success!")
            print(artists)
        }, error: { err in
            print(err)
        })
    }
    
    @IBAction func lastFMTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.red, followed: UIColor.white)
        
        UIView.animate(withDuration: 2.0, animations: {
//            self.spotifyButton.isHidden = true
            self.spotifyButton.alpha = 0.0
            self.manualButton.isHidden = true
        })
        
//        let lastFM = LastFM()
//        lastFM.getArtists(user: "TehPolecat", progress: { progress in
//            print(progress)
//        }, completion: { artists in
//            print(artists)
//        }, error: {error in
//            print(error)
//        })
        
    }
    
    @IBAction func spotifyTap(_ sender: Any) {
         self.backgroundView.updateGradient(with: UIColor.green, followed: UIColor.black)
        
        spotify.authorize()
    }
    
    @IBAction func manualTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.white, followed: UIColor.blue)
    }
    
}



