//
//  Settings.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import Foundation

class Settings {
    
    let defaults = UserDefaults.standard
    
    // Search Radius in Miles
    var radius: Int {
        didSet {
            defaults.set(radius, forKey: Keys.radius)
        }
    }
    
    var location: String? {
        didSet {
            defaults.set(location, forKey: Keys.location)
        }
    }
    
    var launchedBefore: Bool {
        didSet {
            defaults.set(launchedBefore, forKey: Keys.launchedBefore)
        }
    }
    
    var lat: Double {
        didSet {
            defaults.set(lat, forKey: Keys.lat)
        }
    }
    
    var long: Double {
        didSet {
            defaults.set(long, forKey: Keys.long)
        }
    }
    
    struct Keys {
        static let radius = "radius"
        static let location = "location"
        static let lat = "lat"
        static let long = "long"
        static let launchedBefore = "launchedBefore"
    }
    
    init() {
        if let radius = defaults.object(forKey: Keys.radius) as? Int {
            self.radius = radius
        } else {
            self.radius = 100
        }
        
        location = defaults.string(forKey: Keys.location)
        
        launchedBefore = defaults.bool(forKey: Keys.launchedBefore)
        
        if let lat = defaults.object(forKey: Keys.lat) as? Double {
            self.lat = lat
        } else {
            self.lat = 0
        }
        
        if let long = defaults.object(forKey: Keys.long) as? Double {
            self.long = long
        } else {
            self.long = 0
        }
    }
}
