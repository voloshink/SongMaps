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
    
    weak var coordinator: MainCoordinator?
    let locationManager = CLLocationManager()
    
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
        //        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        settings.location = location.coordinate.geohash(length: 10)
        coordinator?.goToMain()
        
    }
    
    @IBAction func requestTap(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
    }
}
