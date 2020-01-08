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
    weak var coordinator: MainCoordinator?
    
    var firstLaunch = false
    var locationRequestRejected = false
    var events = [Event]()
    var artists = [Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCoreData()
        loadArtists()
        loadEvents()
        print("Did load!")
        locationManager.delegate = self
        
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
        // TODO
        settings.lat = 42.380199
        settings.long = -71.134697
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
        print("Got location")
        settings.location = location.coordinate.geohash(length: 10)
        settings.lat = location.coordinate.latitude
        settings.long = location.coordinate.longitude
        getEvents()
    }
    
    // MARK: - CoreData
    private func initializeCoreData() {
        container = NSPersistentContainer(name: "SongMaps")
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    private func saveContext() {
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
    
    private func loadEvents() {
        let request = Event.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]

        do {
            events = try container.viewContext.fetch(request)
            print("Got \(events.count) events")
            guard let viewControllers = self.viewControllers else {
                return
            }
            for case let viewController as EventHandler in viewControllers {
                viewController.newEvents(events: events)
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    private func loadArtists() {
        let request = Artist.createFetchRequest()
        
        do {
            artists = try container.viewContext.fetch(request)
            print("Got \(artists.count) artists")
        } catch {
            print("Fetch Failed")
        }
    }
    
    // MARK: - Private
    private func getEvents() {
        //        ticketmaster.getNewEvents(location: settings.location!, radius: settings.radius)
        ticketmaster.getNewEvents(geoPoint: "drt2zp2mr", radius: 100, completion: { events in
            print(events.count)
            print(events[0])
            self.saveContext()
            self.loadEvents()
        }, error: {error in
            print(error)
        })
    }
}

protocol EventHandler {
    func newEvents(events: [Event])
}
