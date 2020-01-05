//
//  LocationRequestViewController.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import CoreLocation

class LocationRequestViewController: UIViewController, Storyboarded, CLLocationManagerDelegate{

    @IBOutlet var backgroundView: FluidBackgroundView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var requestButton: RoundedButton!
    let locationManager = CLLocationManager()
    
    
    override func viewWillAppear(_ animated: Bool) {
        if settings.location != nil {
            performSegue(withIdentifier: "segueToHome", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO handle error
        print("error!")
        print(error)
        // DEBUG
//        performSegue(withIdentifier: "segueToHome", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            // TODO handle error
            return
        }

        settings.location = location.coordinate.geohash(length: 10)
        print(settings.location!)
        performSegue(withIdentifier: "segueToHome", sender: self)
    }
    
    @IBAction func requestTap(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
    }
}
