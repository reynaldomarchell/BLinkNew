import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<BusJourneyAttributes>?
    private let userDefaults = UserDefaults(suiteName: "group.developer.blink")
    
    private init() {
        // Check if there's an active journey stored
        loadSavedJourney()
    }
    
    func startBusJourney(busInfo: BusInfo, destination: String) {
        // First, end any existing journey to prevent multiple journeys
        Task {
            await forceEndAllActivities()
            
            // Then start the new journey
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                print("Live Activities not supported")
                return
            }
            
            // Save journey info to UserDefaults
            saveJourneyInfo(busInfo)
            
            let attributes = BusJourneyAttributes(
                busPlateNumber: busInfo.plateNumber,
                routeCode: busInfo.routeCode,
                routeName: busInfo.routeName,
                startTime: Date(),
                totalDistance: busInfo.distance // Include total distance for progress calculation
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
    }
    
    func updateBusJourney(currentLocation: String, timeRemaining: TimeInterval, distanceRemaining: Double) {
        guard let activity = currentActivity else { return }
        
        // Remove "En route to" prefix - just use the station name directly
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
    
    // Synchronous version that doesn't wait for completion
    func endBusJourney() {
        // First clear the saved journey from UserDefaults
        clearSavedJourney()
        
        // Then end the activity if it exists
        if let activity = currentActivity {
            let finalState = BusJourneyAttributes.ContentState(
                currentLocation: activity.content.state.destination,
                destination: activity.content.state.destination,
                estimatedTimeRemaining: 0,
                distanceRemaining: 0
            )
            
            Task {
                let finalContent = ActivityContent(state: finalState, staleDate: nil)
                await activity.end(finalContent, dismissalPolicy: .immediate)
                self.currentActivity = nil
                print("Live Activity ended successfully")
            }
        } else {
            print("No active journey to end")
        }
    }
    
    // Async version that waits for completion
    func endBusJourneyAsync() async {
        // First clear the saved journey from UserDefaults
        clearSavedJourney()
        
        // Then end the activity if it exists
        if let activity = currentActivity {
            let finalState = BusJourneyAttributes.ContentState(
                currentLocation: activity.content.state.destination,
                destination: activity.content.state.destination,
                estimatedTimeRemaining: 0,
                distanceRemaining: 0
            )
            
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            
            // End the activity and wait for it to complete
            await activity.end(finalContent, dismissalPolicy: .immediate)
            
            // Also try to end all activities with the same attributes (in case there are duplicates)
            for activity in Activity<BusJourneyAttributes>.activities {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
            
            self.currentActivity = nil
            print("Live Activity ended successfully")
        } else {
            print("No active journey to end")
            
            // Try to end any activities that might be running but not tracked by this instance
            for activity in Activity<BusJourneyAttributes>.activities {
                let finalState = BusJourneyAttributes.ContentState(
                    currentLocation: activity.content.state.destination,
                    destination: activity.content.state.destination,
                    estimatedTimeRemaining: 0,
                    distanceRemaining: 0
                )
                let finalContent = ActivityContent(state: finalState, staleDate: nil)
                await activity.end(finalContent, dismissalPolicy: .immediate)
                print("Found and ended orphaned activity")
            }
        }
    }
    
    // Save journey info to UserDefaults
    private func saveJourneyInfo(_ busInfo: BusInfo) {
        guard let userDefaults = userDefaults else { return }
        
        let journeyData: [String: Any] = [
            "plateNumber": busInfo.plateNumber,
            "routeCode": busInfo.routeCode,
            "routeName": busInfo.routeName,
            "startPoint": busInfo.startPoint,
            "endPoint": busInfo.endPoint,
            "estimatedTime": busInfo.estimatedTime,
            "distance": busInfo.distance,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        userDefaults.set(journeyData, forKey: "activeJourney")
        userDefaults.synchronize()
        
        print("Journey saved to UserDefaults")
    }
    
    // Load saved journey from UserDefaults
    private func loadSavedJourney() {
        guard let userDefaults = userDefaults else { return }
        
        if userDefaults.dictionary(forKey: "activeJourney") != nil {
            print("Found saved journey in UserDefaults")
        }
    }
    
    // Clear saved journey from UserDefaults
    private func clearSavedJourney() {
        guard let userDefaults = userDefaults else { return }
        userDefaults.removeObject(forKey: "activeJourney")
        userDefaults.synchronize()
        print("Cleared saved journey from UserDefaults")
    }
    
    // Get current journey info from UserDefaults
    func getCurrentJourneyInfo() -> BusInfo? {
        guard let userDefaults = userDefaults,
              let journeyData = userDefaults.dictionary(forKey: "activeJourney"),
              let plateNumber = journeyData["plateNumber"] as? String,
              let routeCode = journeyData["routeCode"] as? String,
              let routeName = journeyData["routeName"] as? String,
              let startPoint = journeyData["startPoint"] as? String,
              let endPoint = journeyData["endPoint"] as? String,
              let estimatedTime = journeyData["estimatedTime"] as? Int,
              let distance = journeyData["distance"] as? Double else {
            return nil
        }
        
        return BusInfo(
            plateNumber: plateNumber,
            routeCode: routeCode,
            routeName: routeName,
            startPoint: startPoint,
            endPoint: endPoint,
            estimatedTime: estimatedTime,
            distance: distance
        )
    }
    
    // Check if there's an active journey
    func hasActiveJourney() -> Bool {
        return userDefaults?.dictionary(forKey: "activeJourney") != nil
    }
    
    // Force end all activities (for emergency cleanup)
    func forceEndAllActivities() async {
        // Clear saved journey data
        clearSavedJourney()
        
        // End current activity if it exists
        if let activity = currentActivity {
            let finalState = BusJourneyAttributes.ContentState(
                currentLocation: "Destination",
                destination: "Destination",
                estimatedTimeRemaining: 0,
                distanceRemaining: 0
            )
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            
            await activity.end(finalContent, dismissalPolicy: .immediate)
            currentActivity = nil
        }
        
        // Try to end all activities that might be running
        for activity in Activity<BusJourneyAttributes>.activities {
            let finalState = BusJourneyAttributes.ContentState(
                currentLocation: "Destination",
                destination: "Destination",
                estimatedTimeRemaining: 0,
                distanceRemaining: 0
            )
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ended activity with ID: \(activity.id)")
        }
        
        print("Force ended all activities")
    }
}
