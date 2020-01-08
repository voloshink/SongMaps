//
//  Ticketmaster.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class Ticketmaster {
    
    let apiKey: String
    let size = 100
    let classificationId = "KZFzniwnSyZfZ7v7nJ"
    let sort = "date,asc"
    var container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
           let nsDictionary = NSDictionary(contentsOfFile: path)
            apiKey = nsDictionary!["ticketmaster"] as! String
        } else {
            fatalError("TicketMaster key not found")
        }
    }
    
    func getNewEvents(geoPoint: String, radius: Int, page: Int = 1, progress: @escaping () -> (), completion: @escaping () -> (), error errorCallback: @escaping (String) -> ()) {
        let url = "https://app.ticketmaster.com/discovery/v2/events.json"
        let parameters: [String: String] = [
            "size": String(size),
            "apikey": apiKey,
            "geoPoint": geoPoint,
            "classificationId": classificationId,
            "radius": String(radius),
            "sort": sort,
            "page": String(page),
        ]
        
        AF.request(url, method: .get, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let newEvents = json["_embedded"]["events"].arrayValue
                let totalPages = json["page"]["totalPages"].int ?? 0
                let currentPage = json["page"]["number"].int ?? 0
                print("Loaded page " + String(currentPage))
                self.parseEvents(json: newEvents)
                if currentPage < totalPages {
                    
                    // TODO
//                    completion(self.parseEvents(json: allEvents))
//                    return

                    // hard api limit
                    if (self.size * (page + 1) >= 1000) {
                        completion()
                    } else {
                        progress()
                        let seconds = 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.getNewEvents(geoPoint: geoPoint, radius: radius, page: page + 1, progress: progress, completion: completion, error: errorCallback)
                        }
                    }
                } else {
                    completion()
                }
                
            case .failure(let error):
             print(error)
             print(response.request?.url)
             if (response.response?.statusCode == 429) {
                let seconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.getNewEvents(geoPoint: geoPoint, radius: radius, page: page, progress: progress, completion: completion, error: errorCallback)
                }
             } else {
                errorCallback("Error Getting Events")
             }
            }
        }
    }
    
    private func parseEvents(json: [JSON]) {
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let dateFormatter = ISO8601DateFormatter()
        
        for event in json {
            let name = event["name"].string ?? "Event"
            let id = event["id"].string ?? "unknownevent"
            let url = event["url"].string ?? "https://www.ticketmaster.com/"
            let image = getBiggestImage(json: event["images"].arrayValue) ?? "https://media.ticketmaster.eu/cdn-be/mnxweb46.2.0/static/images/staticPages/social.png"
            let distance = event["distance"].float ?? 0
            let priceRange = event["priceRanges"].arrayValue
            var minPrice: Float = 0.0
            var maxPrice: Float = 0.0
            var currency = ""
            if priceRange.count > 0 {
                minPrice = priceRange[0]["min"].floatValue
                maxPrice = priceRange[0]["max"].floatValue
                currency = priceRange[0]["currency"].stringValue
            }
            
            let dates = event["dates"]
            guard let startDateString = dates["start"]["dateTime"].string else {
                continue
            }
            
            let startDate = dateFormatter.date(from: startDateString)
            let embedded = event["_embedded"]
            let venues = embedded["venues"].arrayValue
            guard venues.count > 0 else {
                continue
            }
            
            let attractions = embedded["attractions"].arrayValue
            guard attractions.count > 0 else {
                continue
            }
            
            var artists = [String]()
            for attraction in attractions {
                guard let artist = attraction["name"].string else {
                    continue
                }
                
                artists.append(artist)
            }
            
            let venue = venues[0]
            let venueName = venue["name"].string ?? "Venue"
            let location  = venue["location"]
            let lat = Float(location["latitude"].string ?? "0") ?? 0.0
            let long = Float(location["longitude"].string ?? "0") ?? 0.0
            
            let e = Event(context: container.viewContext)
            e.name = name
            e.id = id
            e.url = url
            e.image = image
            e.distance = distance
            e.minPrice = minPrice
            e.maxPrice = maxPrice
            e.currency = currency
            e.date = startDate ?? Date()
            e.venue = venueName
            e.lat = lat
            e.long = long
            e.artists = artists.joined(separator: "|")
        }
    }
    
    private func getBiggestImage(json: [JSON]) -> String? {
        
        var maxHeight = 0
        var url: String?
        for image in json {
            let ratio = image["ratio"].string ?? "ratio"
            guard ratio == "16_9" else {
                continue
            }
            
            let height = image["height"].int ?? 0
            if height > maxHeight {
                maxHeight = height
                url = image["url"].string
            }
        }
        
        return url
    }
}
