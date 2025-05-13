//
//  ScanResultView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import SwiftData

struct ScanResultView: View {
    let plateNumber: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Query bus info and routes
    @Query private var busInfos: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    // Find the matching bus info for the scanned plate with improved matching
    private var matchingBusInfo: BusInfo? {
        // Normalize the input plate number for comparison
        let normalizedPlate = normalizePlateForComparison(plateNumber)
        
        // Debug print
        print("Looking for plate: \(plateNumber)")
        print("Normalized input plate: \(normalizedPlate)")
        print("Available bus infos: \(busInfos.map { "\($0.plateNumber) -> \(normalizePlateForComparison($0.plateNumber))" }.joined(separator: ", "))")
        
        // Try to find a match using normalized comparison
        return busInfos.first { busInfo in
            let normalizedBusPlate = normalizePlateForComparison(busInfo.plateNumber)
            let matches = normalizedPlate == normalizedBusPlate
            
            if matches {
                print("✅ Matched: \(plateNumber) with \(busInfo.plateNumber)")
            }
            
            return matches
        }
    }
    
    // Find the route for the bus
    private var busRoute: BusRoute? {
        guard let routeCode = matchingBusInfo?.routeCode else { return nil }
        return busRoutes.first { $0.routeCode == routeCode }
    }
    
    // Route info based on the bus info
    private var routeInfo: (code: String, name: String, color: String) {
        if let busInfo = matchingBusInfo, let route = busRoute {
            return (busInfo.routeCode, route.routeName, route.color)
        }
        // Fallback if no matching bus info is found
        return ("--", "Unknown Route", "gray")
    }
    
    // Get stations from the route
    private var stations: [Station] {
        if let route = busRoute {
            // Use actual stations from the route
            return route.stations.enumerated().map { index, station in
                // Add simulated arrival times for display purposes
                var stationWithTime = station
                stationWithTime.arrivalTime = createTime(hour: 9, minute: 26 + (index * 5))
                return stationWithTime
            }
        }
        // Fallback if no route is found
        return []
    }
    
    // Modify the body property to show an error message for unrecognized plates
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .padding()
            }
            
            // Bus plate number
            Text("Bus Plate: \(formatPlateForDisplay(plateNumber))")
                .font(.headline)
                .padding(.bottom, 10)
            
            if isRecognizedPlate {
                // Route code badge
                ZStack {
                    Circle()
                        .fill(colorFromString(routeInfo.color))
                        .frame(width: 50, height: 50)
                    
                    Text(routeInfo.code)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                
                // Route name
                Text(routeInfo.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Loop Line")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                if stations.isEmpty {
                    // Show message if no stations are found
                    VStack(spacing: 20) {
                        Image(systemName: "bus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No route information available")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("This bus may not be in service or on a different route")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                } else {
                    // Stations list
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(stations.enumerated()), id: \.offset) { index, station in
                                StationRow(station: station, isLast: index == stations.count - 1, routeColor: colorFromString(routeInfo.color))
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding()
                    }
                }
            } else {
                // Show error message for unrecognized plates
                VStack(spacing: 25) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .padding(.top, 30)
                    
                    Text("Plate Number \nNot Recognized")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("This bus plate is not in our database. Please make sure you've correctly positioned the camera and try again.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(spacing: 15) {
                        Text("Tips:")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                        
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Make sure the plate is clearly visible and well-lit")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Avoid scanning when the bus is moving")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Position the plate within \nthe scanning frame")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 20)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .onAppear {
            // Debug print to check what's happening
            print("Scanned plate: \(plateNumber)")
            print("Normalized plate for comparison: \(normalizePlateForComparison(plateNumber))")
            print("Available bus infos: \(busInfos.count)")
            print("Available bus infos: \(busInfos.map { "\($0.plateNumber): \($0.routeCode)" }.joined(separator: ", "))")
            
            if let match = matchingBusInfo {
                print("Found matching bus info: \(match.plateNumber) with route \(match.routeCode)")
                updateLastSeen()
            } else {
                // Check if this plate is in the predefined list in DataSeeder
                if isPredefinedPlate(plateNumber) {
                    print("Plate is in predefined list but not in database, adding it")
                    addPredefinedBusInfo()
                } else {
                    print("No matching bus info found in database")
                    // We don't add plates that aren't in our predefined list
                }
            }
        }
    }
    
    // Function to normalize plate number for comparison
    private func normalizePlateForComparison(_ plate: String) -> String {
        // Remove all spaces, punctuation, and convert to uppercase
        let normalized = plate.uppercased()
            .filter { $0.isLetter || $0.isNumber }
        
        print("Normalized plate: \(normalized) from original: \(plate)")
        return normalized
    }
    
    private func saveBusInfo() {
        // We don't want to save bus info for plates that aren't in our predefined list
        // This function is now just used to update the last seen time for known buses
        
        // The matchingBusInfo computed property already checks if the plate exists
        // If it doesn't find a match, we don't need to do anything here
        print("No matching bus info found in database for plate: \(plateNumber)")
        // We don't insert anything into the database for unknown plates
    }

    // Add a new computed property to check if the plate is recognized
    private var isRecognizedPlate: Bool {
        return matchingBusInfo != nil
    }
    
    private func updateLastSeen() {
        if let busInfo = matchingBusInfo {
            busInfo.lastSeen = Date()
            
            // Try to save the changes
            do {
                try modelContext.save()
                print("Updated last seen for bus: \(busInfo.plateNumber)")
            } catch {
                print("Error updating last seen time: \(error.localizedDescription)")
            }
        }
    }
    
    // Check if the plate is in the predefined list in DataSeeder
    private func isPredefinedPlate(_ plate: String) -> Bool {
        // List of predefined plates from DataSeeder - update to match the no-space format
        let predefinedPlates = [
            "B7566PAA", "B7266JF", "B7466PAA", "B7366JE",
            "B7366PAA", "B7866PAA", "B7666PAA", "B7966PAA",
            "B7002PGX", "B7166PAA", "B7766PAA" // Removed duplicate B7866PAA
        ]
        
        // Normalize the input plate and all predefined plates for comparison
        let normalizedInput = normalizePlateForComparison(plate)
        
        let result = predefinedPlates.contains { predefinedPlate in
            let normalizedPredefined = normalizePlateForComparison(predefinedPlate)
            let matches = normalizedInput == normalizedPredefined
            
            // Debug output
            if matches {
                print("✅ Matched plate \(plate) with predefined \(predefinedPlate)")
            }
            
            return matches
        }
        
        if !result {
            print("❌ No match found for plate: \(plate)")
        }
        
        return result
    }

    // Add a bus info entry for a predefined plate
    private func addPredefinedBusInfo() {
        // Map of predefined plates to their route info - update to match the no-space format
        let plateToRouteMap: [String: (code: String, name: String)] = [
            "B7566PAA": ("GS", "Greenwich - Sektor 1.3 Loop Line"),
            "B7266JF": ("GS", "Greenwich - Sektor 1.3 Loop Line"),
            "B7466PAA": ("GS", "Greenwich - Sektor 1.3 Loop Line"),
            "B7366JE": ("ID1", "Intermoda - De Park 1"),
            "B7366PAA": ("ID2", "Intermoda - De Park 2"),
            "B7866PAA": ("ID2", "Intermoda - De Park 2"), // This key was duplicated
            "B7666PAA": ("IS", "Intermoda - Halte Sektor 1.3"),
            "B7966PAA": ("IS", "Intermoda - Halte Sektor 1.3"),
            "B7002PGX": ("EC", "Electric Line | Intermoda - ICE - QBIG - Ara Rasa - The Breeze - Digital Hub - AEON Mall Loop Line"),
            "B7166PAA": ("BC", "The Breeze - AEON - ICE - The Breeze Loop Line"),
            // Removed duplicate key B7866PAA
            "B7766PAA": ("IV", "Intermoda - Vanya")
        ]
        
        // Normalize the input plate for comparison
        let normalizedInput = normalizePlateForComparison(plateNumber)
        
        // Find the matching route info using normalized comparison
        let matchingKey = plateToRouteMap.keys.first { normalizedKey in
            normalizedInput == normalizePlateForComparison(normalizedKey)
        }
        
        if let matchingKey = matchingKey, let routeInfo = plateToRouteMap[matchingKey] {
            // Use the original format from the database for consistency
            let formattedPlate = matchingKey
            
            // Create and insert the bus info
            let busInfo = BusInfo(
                plateNumber: formattedPlate,
                routeCode: routeInfo.code,
                routeName: routeInfo.name
            )
            
            // Check for duplicates one more time before inserting
            let duplicateCheck = busInfos.first { busInfo in
                normalizePlateForComparison(busInfo.plateNumber) == normalizedInput
            }
            
            if duplicateCheck == nil {
                modelContext.insert(busInfo)
                
                // Try to save changes
                do {
                    try modelContext.save()
                    print("Added predefined bus info for plate: \(formattedPlate)")
                } catch {
                    print("Error adding predefined bus info: \(error.localizedDescription)")
                }
            } else {
                print("Duplicate check caught a potential duplicate entry")
            }
        }
    }
    
    // Format a plate number in the standard format: B 1234 XYZ
    private func formatPlateNumber(_ plate: String) -> String? {
        // Remove spaces and convert to uppercase
        let cleaned = plate.uppercased().filter { !$0.isWhitespace }
        
        // Try to extract components
        var regionCode = ""
        var numbers = ""
        var identifier = ""
        
        var index = cleaned.startIndex
        
        // Extract region code (first 1-2 letters)
        while index < cleaned.endIndex && cleaned[index].isLetter {
            regionCode.append(cleaned[index])
            index = cleaned.index(after: index)
        }
        
        // Extract numbers
        while index < cleaned.endIndex && cleaned[index].isNumber {
            numbers.append(cleaned[index])
            index = cleaned.index(after: index)
        }
        
        // Extract identifier (remaining letters)
        while index < cleaned.endIndex && cleaned[index].isLetter {
            identifier.append(cleaned[index])
            index = cleaned.index(after: index)
        }
        
        // Format with proper spacing
        if !regionCode.isEmpty && !numbers.isEmpty {
            if !identifier.isEmpty {
                return "\(regionCode) \(numbers) \(identifier)"
            } else {
                return "\(regionCode) \(numbers)"
            }
        }
        
        return nil
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "lightblue": return Color(red: 64/255, green: 224/255, blue: 208/255)
        case "pink": return Color(red: 219/255, green: 112/255, blue: 147/255)
        case "darkgreen": return Color(red: 154/255, green: 205/255, blue: 50/255)
        case "navy": return Color(red: 0/255, green: 0/255, blue: 128/255)
        case "red": return .red
        case "black": return Color(red: 128/255, green: 128/255, blue: 128/255) // Changed from black to gray for better visibility in dark mode
        default: return .gray
        }
    }

    // Add a new function to format plate numbers for display
    private func formatPlateForDisplay(_ plate: String) -> String {
        // If the plate already has spaces, return it as is
        if plate.contains(" ") {
            return plate
        }
        
        // Otherwise, format it with spaces
        return formatPlateNumber(plate) ?? plate
    }
}

struct StationRow: View {
    let station: Station
    let isLast: Bool
    let routeColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Station indicator and line
            VStack(spacing: 0) {
                Circle()
                    .fill(stationColor)
                    .frame(width: 20, height: 20)
                
                if !isLast {
                    Rectangle()
                        .fill(routeColor)
                        .frame(width: 3)
                        .frame(height: 40)
                }
            }
            
            // Station info
            VStack(alignment: .leading, spacing: 2) {
                if station.isPreviousStation {
                    Text("Previous station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if station.isCurrentStation {
                    Text("Current station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if station.isNextStation {
                    Text("Next station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(station.name)
                    .font(.headline)
            }
            .padding(.vertical, 5)
            
            Spacer()
            
            // Arrival time
            if let time = station.arrivalTime {
                Text(timeFormatter.string(from: time))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    private var stationColor: Color {
        if station.isPreviousStation {
            return routeColor.opacity(0.5)
        } else if station.isCurrentStation {
            return routeColor
        } else if station.isNextStation {
            return routeColor
        } else {
            return routeColor
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter
    }
}


#Preview {
    ScanResultView(plateNumber: "B 7566 PAA")
}
