import SwiftUI
import SwiftData

@main
struct BLinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [BusRoute.self, BusInfo.self])
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataInitialized = false
    
    var body: some View {
        ZStack {
            // Main content
            if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                // Not first launch, go directly to HomeView
                HomeView()
            } else {
                // First launch, show tutorial with HomeView as the destination
                HomeView()
                    .fullScreenCover(isPresented: .constant(true)) {
                        TutorialView()
                    }
            }
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
