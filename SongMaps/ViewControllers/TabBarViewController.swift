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
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    weak var coordinator: MainCoordinator?
    
    var loadingEvents = false
    var locationRequestRejected = false
    var events = [Event]()
    var artists = [Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadArtists()
        loadEvents()
        locationManager.delegate = self
        
        ticketmaster = Ticketmaster(container: container)
        if settings.launchedBefore {
            print("requesting location")
            locationManager.requestLocation()
        } else {
            settings.launchedBefore = true
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
    func saveContext() {
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
            let unfilteredEvents = try container.viewContext.fetch(request)
            print("Loaded \(unfilteredEvents.count) unfiltered events from disk")
            var matchedEvents = [Event]()
            
            DispatchQueue.global(qos: .background).async {
                var artistNames = Set<String>()
                for artist in self.artists {
                    artistNames.insert(artist.name.lowercased())
                }

                for event in unfilteredEvents {
                    let eventArtists = event.artists.lowercased().components(separatedBy: "|")
                    for eventArtist in eventArtists {
                        if (artistNames.contains(eventArtist)) {
                            matchedEvents.append(event)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.events = matchedEvents
                    print("Matched \(matchedEvents.count) events from disk")
                    guard let viewControllers = self.viewControllers else {
                        return
                    }
                    
                    for case let viewController as EventHandler in viewControllers {
                        viewController.newEvents(events: self.events)
                    }
                }
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    func loadArtists() {
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
        guard !loadingEvents else {
            return
        }

        loadingEvents = true
        //        ticketmaster.getNewEvents(location: settings.location!, radius: settings.radius)
        ticketmaster.getNewEvents(geoPoint: "drt2zp2mr", radius: 100, progress: {
            self.saveContext()
            self.loadEvents()
            },
            completion: {
            self.saveContext()
            self.loadEvents()
            self.loadingEvents = false
        }, error: {error in
            print("get new events error VV")
            print(error)
            self.loadingEvents = false
        })
    }
}

protocol EventHandler {
    func newEvents(events: [Event])
}
