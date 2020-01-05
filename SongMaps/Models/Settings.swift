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
    
    struct Keys {
        static let radius = "radius"
        static let location = "location"
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
    }
}
