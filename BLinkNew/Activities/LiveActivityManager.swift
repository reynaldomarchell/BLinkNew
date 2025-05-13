import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<BusJourneyAttributes>?
    
    private init() {}
    
    func startBusJourney(busInfo: BusInfo, destination: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not supported")
            return
        }
        
        let attributes = BusJourneyAttributes(
            busPlateNumber: busInfo.plateNumber,
            routeCode: busInfo.routeCode,
            routeName: busInfo.routeName,
            startTime: Date()
        )
        
        let initialState = BusJourneyAttributes.ContentState(
            currentLocation: busInfo.startPoint,
            destination: destination,
            estimatedTimeRemaining: TimeInterval(busInfo.estimatedTime * 60),
            distanceRemaining: busInfo.distance
        )
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("Live Activity started with ID: \(currentActivity?.id ?? "unknown")")
        } catch {
            print("Error starting live activity: \(error.localizedDescription)")
        }
    }
    
    func updateBusJourney(currentLocation: String, timeRemaining: TimeInterval, distanceRemaining: Double) {
        guard let activity = currentActivity else { return }
        
        let updatedState = BusJourneyAttributes.ContentState(
            currentLocation: currentLocation,
            destination: activity.content.state.destination,
            estimatedTimeRemaining: timeRemaining,
            distanceRemaining: distanceRemaining
        )
        
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(updatedContent)
        }
    }
    
    func endBusJourney() {
        guard let activity = currentActivity else { return }
        
        let finalState = BusJourneyAttributes.ContentState(
            currentLocation: activity.content.state.destination,
            destination: activity.content.state.destination,
            estimatedTimeRemaining: 0,
            distanceRemaining: 0
        )
        
        Task {
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
