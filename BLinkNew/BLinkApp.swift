//
//  BLinkApp.swift
//  BLink
//
//  Created by reynaldo on 24/03/25.
//

import SwiftUI
import SwiftData

@main
struct BLinkApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    // Create a shared model container
                    let modelContainer = try! ModelContainer(for: BusRoute.self, BusInfo.self)
                    let context = modelContainer.mainContext
                    
                    // Check if data exists
                    do {
                        let routeDescriptor = FetchDescriptor<BusRoute>()
                        let routeCount = try context.fetchCount(routeDescriptor)
                        
                        print("Found \(routeCount) routes in database")
                        
                        if routeCount == 0 {
                            print("No routes found, seeding initial data")
                            // Clear any existing data first to avoid duplicates
                            DataSeeder.clearAllData(modelContext: context)
                            DataSeeder.seedInitialData(modelContext: context)
                            
                            // Verify seeding worked
                            let verifyCount = try context.fetchCount(routeDescriptor)
                            print("After seeding: \(verifyCount) routes in database")
                        } else {
                            print("Routes already exist, skipping seed")
                        }
                    } catch {
                        print("Error checking data: \(error)")
                        // If there's an error, try to seed anyway
                        DataSeeder.clearAllData(modelContext: context)
                        DataSeeder.seedInitialData(modelContext: context)
                    }
                }
        }
        .modelContainer(for: [BusRoute.self, BusInfo.self])
    }
}

