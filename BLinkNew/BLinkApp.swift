import SwiftUI
import SwiftData
import ActivityKit

@main
struct BLinkApp: App {
    @State private var deepLinkJourney = false
    @State private var deepLinkPlateNumber: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkJourney: $deepLinkJourney, deepLinkPlateNumber: $deepLinkPlateNumber)
                .modelContainer(for: [BusRoute.self, BusInfo.self])
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
                .task {
                    // Check for any orphaned activities on app launch
                    await cleanupOrphanedActivities()
                }
        }
    }
    
    private func handleDeepLink(url: URL) {
        print("Received deep link: \(url)")
        
        // Simple URL scheme handling
        if url.scheme == "blink" && url.host == "journey" {
            print("Deep link to journey detected")
            
            // Check if there's a plate number in the path
            if url.pathComponents.count > 1 {
                let plateNumber = url.pathComponents[1]
                print("Deep link contains plate number: \(plateNumber)")
                deepLinkPlateNumber = plateNumber
            }
            
            deepLinkJourney = true
        }
    }
    
    // Cleanup any orphaned activities on app launch
    private func cleanupOrphanedActivities() async {
        // If we have UserDefaults journey data but no active Live Activity, clean up
        if LiveActivityManager.shared.hasActiveJourney() {
            var hasMatchingActivity = false
            
            // Check if there's a matching Live Activity
            for _ in Activity<BusJourneyAttributes>.activities {
                hasMatchingActivity = true
                break
            }
            
            // If no matching activity found, clean up the UserDefaults data
            if !hasMatchingActivity {
                print("Found orphaned journey data without active Live Activity, cleaning up")
                await LiveActivityManager.shared.forceEndAllActivities()
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataInitialized = false
    @State private var showTutorial = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @Binding var deepLinkJourney: Bool
    @Binding var deepLinkPlateNumber: String?
    
    init(deepLinkJourney: Binding<Bool> = .constant(false), deepLinkPlateNumber: Binding<String?> = .constant(nil)) {
        self._deepLinkJourney = deepLinkJourney
        self._deepLinkPlateNumber = deepLinkPlateNumber
    }
    
    var body: some View {
        // Main content
        HomeView(deepLinkJourney: deepLinkJourney, deepLinkPlateNumber: deepLinkPlateNumber)
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialView(showTutorial: $showTutorial)
            }
            .onAppear {
                initializeData()
            }
    }
    
    private func initializeData() {
        // Check if data exists
        do {
            let routeDescriptor = FetchDescriptor<BusRoute>()
            let routeCount = try modelContext.fetchCount(routeDescriptor)
            
            print("Found \(routeCount) routes in database")
            
            if routeCount == 0 {
                print("No routes found, seeding initial data")
                // Clear any existing data first to avoid duplicates
                DataSeeder.clearAllData(modelContext: modelContext)
                DataSeeder.seedInitialData(modelContext: modelContext)
                
                // Verify seeding worked
                let verifyCount = try modelContext.fetchCount(routeDescriptor)
                print("After seeding: \(verifyCount) routes in database")
            } else {
                print("Routes already exist, skipping seed")
            }
            
            dataInitialized = true
        } catch {
            print("Error checking data: \(error)")
            // If there's an error, try to seed anyway
            DataSeeder.clearAllData(modelContext: modelContext)
            DataSeeder.seedInitialData(modelContext: modelContext)
            dataInitialized = true
        }
    }
}
