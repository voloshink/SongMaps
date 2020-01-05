//
//  TabBarViewController.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class TabBarViewController: UITabBarController, CLLocationManagerDelegate, Storyboarded {
    
    let locationManager = CLLocationManager()
    var ticketmaster: Ticketmaster!
    var container: NSPersistentContainer!
    
    var firstLaunch = false
    var locationRequestRejected = false
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Did load!")
        locationManager.delegate = self
        
        initializeCoreData()
        ticketmaster = Ticketmaster(container: container)
        if !firstLaunch {
            print("requesting location")
            locationManager.requestLocation()
        } else {
            getEvents()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error VVV")
        print(error)
        guard let error = error as? CLError else {
            return
        }
        
        guard error.code == CLError.Code.denied else {
            getEvents()
            return
        }
        
        
        // Only try to ask the user for location once
        guard !locationRequestRejected else {
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        settings.location = location.coordinate.geohash(length: 10)
        getEvents()
    }
    
    // MARK: - CoreData
    private func initializeCoreData() {
        container = NSPersistentContainer(name: "SongMaps")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    func saveContext() {
        guard let container = container else {
            return
        }

        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    // MARK: - Private
    private func getEvents() {
        //        ticketmaster.getNewEvents(location: settings.location!, radius: settings.radius)
        ticketmaster.getNewEvents(geoPoint: "drt2zp2mr", radius: 100, completion: { events in
            print(events.count)
            print(events[0])
        }, error: {error in
            print(error)
        })
    }
}
