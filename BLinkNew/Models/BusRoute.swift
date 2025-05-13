//
//  BusRoute.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import Foundation
import SwiftData

@Model
final class BusRoute {
   var id: UUID
   var routeName: String
   var startPoint: String
   var endPoint: String
   var stations: [Station]
   var routeCode: String
   var color: String
   var estimatedTime: Int // in minutes
   var distance: Double // in km
   var routeDescription: String?
   
   init(id: UUID = UUID(), routeName: String, startPoint: String, endPoint: String, stations: [Station], routeCode: String, color: String, estimatedTime: Int, distance: Double, routeDescription: String? = nil) {
       self.id = id
       self.routeName = routeName
       self.startPoint = startPoint
       self.endPoint = endPoint
       self.stations = stations
       self.routeCode = routeCode
       self.color = color
       self.estimatedTime = estimatedTime
       self.distance = distance
       self.routeDescription = routeDescription
   }
}

// Make Station Codable and Hashable for SwiftData storage
struct Station: Codable, Hashable {
   var name: String
   var arrivalTime: Date?
   var isCurrentStation: Bool
   var isPreviousStation: Bool
   var isNextStation: Bool
   
   // Add explicit initializer to ensure proper initialization
   init(name: String, arrivalTime: Date? = nil, isCurrentStation: Bool = false, isPreviousStation: Bool = false, isNextStation: Bool = false) {
       self.name = name
       self.arrivalTime = arrivalTime
       self.isCurrentStation = isCurrentStation
       self.isPreviousStation = isPreviousStation
       self.isNextStation = isNextStation
   }
}

