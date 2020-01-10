//
//  LastFM.swift
//  SongMaps
//
//  Created by Polecat on 11/12/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class LastFM {
    var page = 1
    let limit = 200
    let urlTemplate = "https://ws.audioscrobbler.com/2.0/?method=user.gettopartists&user=%@&api_key=%@&format=json&limit=%d&page=%d"
    var artists = [String]()
    let apiKey: String
    var retries = 0
    let maxRetries = 10
    
    init() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
           let nsDictionary = NSDictionary(contentsOfFile: path)
            apiKey = nsDictionary!["lastfm"] as! String
        } else {
            fatalError("LastFM key not found")
        }
    }
    
    func getArtists(user: String, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error errorCallback: @escaping (String) -> ()) {
        guard (user.lowercased() != settings.lastFMTestName.lowercased()) else {
            settings.demoMode = true
            progress(1.0)
            completion(["TestArtist"])
            return
        }
        
        settings.demoMode = false

        let url = String(format: urlTemplate, user, apiKey, limit, page)
        AF.request(url).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let topArtists = json["topartists"]["artist"].array else {
                    errorCallback("Received malformed json")
                    return
                }
                
                guard let total = Int(json["topartists"]["@attr"]["total"].stringValue) else {
                    errorCallback("Received malformed json")
                    return
                }
                
                guard let totalPages = Int(json["topartists"]["@attr"]["totalPages"].stringValue) else {
                    errorCallback("Received malformed json")
                    return
                }
                
                for artist in topArtists {
                    guard let name = artist["name"].string else {
                        continue
                    }
                    
                    self.artists.append(name)
                }
                
                progress(Float((self.page * self.limit)) / Float(total))
                
                if self.page < totalPages {
                    self.page += 1
                    usleep(100000)
                    self.getArtists(user: user, progress: progress, completion: completion, error: errorCallback)
                } else {
                    self.retries = 0
                    completion(self.artists)
                }

            case .failure(let error):
                print(response.request?.url)
                print(error)
                if self.retries < self.maxRetries {
                    self.retries += 1
                    self.getArtists(user: user, progress: progress, completion: completion, error: errorCallback)
                } else {
                    errorCallback("Error getting artists for \(user), response code \(response.response?.statusCode ?? 999)")
                }
            }
        }
    }
    
}
