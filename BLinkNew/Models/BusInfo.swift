//
//  BusInfo.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import Foundation
import SwiftData

@Model
final class BusInfo {
    var id: UUID
    var plateNumber: String
    var routeCode: String
    var routeName: String
    var lastSeen: Date
    
    init(id: UUID = UUID(), plateNumber: String, routeCode: String, routeName: String, lastSeen: Date = Date()) {
        self.id = id
        self.plateNumber = plateNumber
        self.routeCode = routeCode
        self.routeName = routeName
        self.lastSeen = lastSeen
    }
}

