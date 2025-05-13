import Foundation
import SwiftData

@Model
final class BusInfo {
    var id: UUID
    var plateNumber: String
    var routeCode: String
    var routeName: String
    var lastSeen: Date
    var startPoint: String
    var endPoint: String
    var estimatedTime: Int // in minutes
    var distance: Double // in km
    
    init(id: UUID = UUID(), plateNumber: String, routeCode: String, routeName: String, lastSeen: Date = Date(), startPoint: String, endPoint: String, estimatedTime: Int, distance: Double) {
        self.id = id
        self.plateNumber = plateNumber
        self.routeCode = routeCode
        self.routeName = routeName
        self.lastSeen = lastSeen
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.estimatedTime = estimatedTime
        self.distance = distance
    }
}
