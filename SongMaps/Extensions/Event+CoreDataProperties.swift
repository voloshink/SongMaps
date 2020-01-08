//
//  Event+CoreDataProperties.swift
//  SongMaps
//
//  Created by Polecat on 1/9/20.
//  Copyright © 2020 Polecat. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var currency: String
    @NSManaged public var date: Date
    @NSManaged public var distance: Float
    @NSManaged public var id: String
    @NSManaged public var image: String
    @NSManaged public var lat: Float
    @NSManaged public var long: Float
    @NSManaged public var maxPrice: Float
    @NSManaged public var minPrice: Float
    @NSManaged public var name: String
    @NSManaged public var url: String
    @NSManaged public var venue: String
    @NSManaged public var artists: String

}
