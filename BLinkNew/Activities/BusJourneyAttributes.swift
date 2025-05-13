import Foundation
import ActivityKit

struct BusJourneyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentLocation: String
        var destination: String
        var estimatedTimeRemaining: TimeInterval
        var distanceRemaining: Double
    }
    
    var busPlateNumber: String
    var routeCode: String
    var routeName: String
    var startTime: Date
}
