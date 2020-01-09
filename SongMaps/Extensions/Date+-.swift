//
//  Date+-.swift
//  SongMaps
//
//  Created by Polecat on 1/9/20.
//  Copyright © 2020 Polecat. All rights reserved.
//

import Foundation

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
