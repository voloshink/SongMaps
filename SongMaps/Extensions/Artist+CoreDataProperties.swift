//
//  Artist+CoreDataProperties.swift
//  SongMaps
//
//  Created by Polecat on 11/12/19.
//  Copyright © 2019 Polecat. All rights reserved.
//
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var name: String
    @NSManaged public var source: String
    @NSManaged public var added: Date

}
