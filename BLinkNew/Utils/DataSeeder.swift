import Foundation
import SwiftData

class DataSeeder {
    static func seedInitialData(modelContext: ModelContext) {
        print("Starting data seeding...")
        
        // Seed bus routes
        let busRoutes = [
            BusRoute(
                routeName: "The Breeze - AEON - ICE - The Breeze Loop Line",
                startPoint: "The Breeze",
                endPoint: "The Breeze",
                stations: [
                    Station(name: "The Breeze", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Selatan", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "AEON Mall 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "AEON Mall 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CDB Utara 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE Business Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Lobby AEON Mall", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Navapark 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Green cove", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
                ],
                routeCode: "BC",
                color: "purple",
                estimatedTime: 65,
                distance: 6.9,
                routeDescription: "The Breeze → AEON → ICE → The Breeze Loop Line"
            ),
            BusRoute(
                routeName: "Greenwich - Sektor 1.3 Loop Line",
                startPoint: "Greenwich Park",
                endPoint: "Halte Sektor 1.3",
                stations: [
                    Station(name: "Greenwich Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Timur 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Selatan", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "AEON Mall 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "AEON Mall 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CDB Utara 3", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE Business Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Lobby AEON Mall", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Timur 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Navapark 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Green cove", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
                ],
                routeCode: "GS",
                color: "green",
                estimatedTime: 65,
                distance: 6.9,
                routeDescription: "Greenwich - Sektor 1.3 Loop Line"
            ),
            BusRoute(
                routeName: "Intermoda - Vanya",
                startPoint: "Intermoda",
                endPoint: "Vanya Park",
                stations: [
                    Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Simplicity 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Edutown 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Edutown 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Prestigia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "The Mozia 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Piazza Mozia", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Tabebuya", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Vanya Park", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "The Mozia 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Illustria", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 6", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "ICE 5", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "CBD Barat 2", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Simplicity 1", isCurrentStation: false, isPreviousStation: false, isNextStation: false),
                    Station(name: "Intermoda", isCurrentStation: false, isPreviousStation: false, isNextStation: false)
                ],
                routeCode: "IV",
                color: "darkgreen",
                estimatedTime: 35,
                distance: 0.3,
                routeDescription: "Intermoda - Vanya Park Loop Line"
            )
        ]
        
        let busInfos = [
            BusInfo(
                plateNumber: "B7566PAA",
                routeCode: "GS",
                routeName: "Greenwich - Sektor 1.3 Loop Line",
                startPoint: "Greenwich Park",
                endPoint: "Halte Sektor 1.3",
                estimatedTime: 25,
                distance: 0.3
            ),
            BusInfo(
                plateNumber: "B7266JF",
                routeCode: "GS",
                routeName: "Greenwich - Sektor 1.3 Loop Line",
                startPoint: "Greenwich Park",
                endPoint: "Halte Sektor 1.3",
                estimatedTime: 25,
                distance: 0.3
            ),
            BusInfo(
                plateNumber: "B7466PAA",
                routeCode: "GS",
                routeName: "Greenwich - Sektor 1.3 Loop Line",
                startPoint: "Greenwich Park",
                endPoint: "Halte Sektor 1.3",
                estimatedTime: 25,
                distance: 0.3
            ),
            BusInfo(
                plateNumber: "B7366JE",
                routeCode: "ID1",
                routeName: "Intermoda - De Park 1",
                startPoint: "Intermoda",
                endPoint: "De Park 1",
                estimatedTime: 30,
                distance: 0.5
            ),
            BusInfo(
                plateNumber: "B7366PAA",
                routeCode: "ID2",
                routeName: "Intermoda - De Park 2",
                startPoint: "Intermoda",
                endPoint: "De Park 2",
                estimatedTime: 35,
                distance: 0.6
            ),
            BusInfo(
                plateNumber: "B7866PAA",
                routeCode: "ID2",
                routeName: "Intermoda - De Park 2",
                startPoint: "Intermoda",
                endPoint: "De Park 2",
                estimatedTime: 35,
                distance: 0.6
            ),
            BusInfo(
                plateNumber: "B7666PAA",
                routeCode: "IS",
                routeName: "Intermoda - Halte Sektor 1.3",
                startPoint: "Intermoda",
                endPoint: "Halte Sektor 1.3",
                estimatedTime: 40,
                distance: 0.7
            ),
            BusInfo(
                plateNumber: "B7966PAA",
                routeCode: "IS",
                routeName: "Intermoda - Halte Sektor 1.3",
                startPoint: "Intermoda",
                endPoint: "Halte Sektor 1.3",
                estimatedTime: 40,
                distance: 0.7
            ),
            BusInfo(
                plateNumber: "B7002PGX",
                routeCode: "EC",
                routeName: "Electric Line | Intermoda - ICE - QBIG - Ara Rasa - The Breeze - Digital Hub - AEON Mall Loop Line",
                startPoint: "Intermoda",
                endPoint: "AEON Mall",
                estimatedTime: 45,
                distance: 0.8
            ),
            BusInfo(
                plateNumber: "B7166PAA",
                routeCode: "BC",
                routeName: "The Breeze - AEON - ICE - The Breeze Loop Line",
                startPoint: "The Breeze",
                endPoint: "The Breeze",
                estimatedTime: 50,
                distance: 0.9
            ),
            BusInfo(
                plateNumber: "B7766PAA",
                routeCode: "IV",
                routeName: "Intermoda - Vanya",
                startPoint: "Intermoda",
                endPoint: "Vanya Park",
                estimatedTime: 25,
                distance: 0.3
            )
        ]
        
        // Insert data into the model context
        for route in busRoutes {
            modelContext.insert(route)
            print("Inserted route: \(route.routeCode)")
        }
        
        for busInfo in busInfos {
            modelContext.insert(busInfo)
        }
        
        // Try to save changes immediately
        do {
            try modelContext.save()
            print("Successfully saved model context after seeding")
        } catch {
            print("Error saving model context: \(error)")
        }
    }
    
    // Function to clear all existing data
    static func clearAllData(modelContext: ModelContext) {
        do {
            // Clear BusInfo
            let busInfoDescriptor = FetchDescriptor<BusInfo>()
            let busInfos = try modelContext.fetch(busInfoDescriptor)
            for busInfo in busInfos {
                modelContext.delete(busInfo)
            }
            
            // Clear BusRoute
            let routeDescriptor = FetchDescriptor<BusRoute>()
            let routes = try modelContext.fetch(routeDescriptor)
            for route in routes {
                modelContext.delete(route)
            }
            
            // Try to save changes immediately
            try modelContext.save()
            print("All existing data cleared successfully")
        } catch {
            print("Error clearing data: \(error)")
        }
    }
    
    // Add a function to update station status based on current time
    static func updateStationStatus(route: BusRoute) {
        // Get the current time
        let currentTime = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        
        // Calculate the total minutes since midnight
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        // Determine which station is current based on time
        // This is a simplified algorithm - in a real app, you'd use actual bus schedules
        let totalStations = route.stations.count
        let cycleTime = route.estimatedTime // minutes for a full cycle
        
        // Calculate which station in the cycle we're at
        let minutesIntoDay = currentTotalMinutes % cycleTime
        let stationIndex = Int(Double(minutesIntoDay) / Double(cycleTime) * Double(totalStations)) % totalStations
        
        // Update station statuses
        for i in 0..<route.stations.count {
            route.stations[i].isCurrentStation = (i == stationIndex)
            route.stations[i].isPreviousStation = (i == (stationIndex - 1 + totalStations) % totalStations)
            route.stations[i].isNextStation = (i == (stationIndex + 1) % totalStations)
            
            // Set arrival times
            let minutesFromNow = ((i - stationIndex + totalStations) % totalStations) * (cycleTime / totalStations)
            route.stations[i].arrivalTime = calendar.date(byAdding: .minute, value: minutesFromNow, to: currentTime)
        }
    }

    // Add a function to get the nearest bus stop
    static func getNearestBusStop(latitude: Double, longitude: Double) -> Station? {
        // This would normally use actual geolocation data
        // For this demo, we'll just return a fixed station
        return Station(
            name: "The Breeze",
            arrivalTime: Date(),
            isCurrentStation: true,
            isPreviousStation: false,
            isNextStation: false
        )
    }
}
