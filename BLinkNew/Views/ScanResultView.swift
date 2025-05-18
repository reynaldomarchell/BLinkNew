import SwiftUI
import SwiftData

struct ScanResultView: View {
    let plateNumber: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Query bus info and routes
    @Query private var busInfos: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    @State private var showJourneyView = false
    @State private var selectedStation: String?
    @State private var forceRefresh = false // Add a state to force refresh
    @State private var isLoading = true // Add this line after other @State variables
    
    // Find the matching bus info for the scanned plate with improved matching
    private var matchingBusInfo: BusInfo? {
        // Normalize the input plate number for comparison
        let normalizedPlate = normalizePlateForComparison(plateNumber)
        
        // Debug print
        print("Looking for plate: \(plateNumber)")
        print("Normalized input plate: \(normalizedPlate)")
        
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
        let route = busRoutes.first { $0.routeCode == routeCode }
        
        if route == nil {
            print("⚠️ No route found for code: \(routeCode)")
            // Debug print all available routes
            for availableRoute in busRoutes {
                print("Available route: \(availableRoute.routeCode)")
            }
        }
        
        return route
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
                // Add simulated arrival times and varying distances for display purposes
                var stationWithTime = station
                stationWithTime.arrivalTime = createTime(hour: 9, minute: 26 + (index * 5))
                return stationWithTime
            }
        }
        // Fallback if no route is found
        return []
    }
    
    // Update the body to handle loading state properly
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                // Loading indicator
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        
                        Text("Loading route information...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Route header with plate number and route code
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Text(formatPlateForDisplay(plateNumber))
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(4)
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(colorFromString(routeInfo.color))
                                        .frame(width: 40, height: 40)
                                    
                                    Text(routeInfo.code)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Text(routeInfo.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        
                        // Stations list
                        if stations.isEmpty {
                            // Show message if no stations are found
                            VStack(spacing: 20) {
                                Spacer()
                                
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
                                
                                Spacer()
                            }
                            .padding(.top, 50)
                        } else {
                            // Stations list
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(stations.enumerated()), id: \.offset) { index, station in
                                        StationRowButton(
                                            station: station,
                                            isLast: index == stations.count - 1,
                                            routeColor: colorFromString(routeInfo.color),
                                            index: index,
                                            onTap: {
                                                selectedStation = station.name
                                                showJourneyView = true
                                            }
                                        )
                                    }
                                }
                                .background(Color(.systemBackground))
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showJourneyView) {
            if let busInfo = matchingBusInfo {
                JourneyView(
                    busInfo: busInfo,
                    initialState: .start,
                    onJourneyComplete: {
                        showJourneyView = false
                    }
                )
            }
        }
        .task {
            // More reliable than onAppear for SwiftData
            await loadData()
        }
        .id(forceRefresh) // Use the state to force a refresh when needed
    }
    
    // Function to normalize plate number for comparison
    private func normalizePlateForComparison(_ plate: String) -> String {
        // Remove all spaces, punctuation, and convert to uppercase
        let normalized = plate.uppercased()
            .filter { $0.isLetter || $0.isNumber }
        
        return normalized
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
    
    // Breaking up the large array into a function to avoid compiler issues
    private func isPredefinedPlate(_ plate: String) -> Bool {
        // Normalize the input plate for comparison
        let normalizedInput = normalizePlateForComparison(plate)
        
        // Check first group of plates
        let group1 = ["B7566PAA", "B7266JF", "B7466PAA", "B7366JE"]
        for predefinedPlate in group1 {
            if normalizedInput == normalizePlateForComparison(predefinedPlate) {
                return true
            }
        }
        
        // Check second group of plates
        let group2 = ["B7366PAA", "B7866PAA", "B7666PAA", "B7966PAA"]
        for predefinedPlate in group2 {
            if normalizedInput == normalizePlateForComparison(predefinedPlate) {
                return true
            }
        }
        
        // Check third group of plates
        let group3 = ["B7002PGX", "B7166PAA", "B7766PAA"]
        for predefinedPlate in group3 {
            if normalizedInput == normalizePlateForComparison(predefinedPlate) {
                return true
            }
        }
        
        return false
    }

    // Simplify the plate-to-route mapping to avoid compiler issues
    private func getRouteInfoForPlate(_ plate: String) -> (code: String, name: String, startPoint: String, endPoint: String)? {
        let normalizedPlate = normalizePlateForComparison(plate)
        
        // Group 1
        if normalizedPlate == normalizePlateForComparison("B7566PAA") ||
           normalizedPlate == normalizePlateForComparison("B7266JF") ||
           normalizedPlate == normalizePlateForComparison("B7466PAA") {
            return ("GS", "Greenwich - Sektor 1.3 Loop Line", "Greenwich Park", "Halte Sektor 1.3")
        }
        
        // Group 2
        if normalizedPlate == normalizePlateForComparison("B7366JE") {
            return ("ID1", "Intermoda - De Park 1", "Intermoda", "De Park 1")
        }
        
        // Group 3
        if normalizedPlate == normalizePlateForComparison("B7366PAA") ||
           normalizedPlate == normalizePlateForComparison("B7866PAA") {
            return ("ID2", "Intermoda - De Park 2", "Intermoda", "De Park 2")
        }
        
        // Group 4
        if normalizedPlate == normalizePlateForComparison("B7666PAA") ||
           normalizedPlate == normalizePlateForComparison("B7966PAA") {
            return ("IS", "Intermoda - Halte Sektor 1.3", "Intermoda", "Halte Sektor 1.3")
        }
        
        // Group 5
        if normalizedPlate == normalizePlateForComparison("B7002PGX") {
            return ("EC", "Electric Line | Intermoda - ICE - QBIG - Ara Rasa - The Breeze - Digital Hub - AEON Mall Loop Line", "Intermoda", "AEON Mall")
        }
        
        // Group 6
        if normalizedPlate == normalizePlateForComparison("B7166PAA") {
            return ("BC", "The Breeze - AEON - ICE - The Breeze Loop Line", "The Breeze", "The Breeze")
        }
        
        // Group 7
        if normalizedPlate == normalizePlateForComparison("B7766PAA") {
            return ("IV", "Intermoda - Vanya", "Intermoda", "Vanya Park")
        }
        
        return nil
    }

    // Simplified version of addPredefinedBusInfo to avoid compiler issues
    private func addPredefinedBusInfo() {
        guard let routeInfo = getRouteInfoForPlate(plateNumber) else {
            print("No matching route info found for plate: \(plateNumber)")
            return
        }
        
        // Create and insert the bus info
        let busInfo = BusInfo(
            plateNumber: plateNumber,
            routeCode: routeInfo.code,
            routeName: routeInfo.name,
            startPoint: routeInfo.startPoint,
            endPoint: routeInfo.endPoint,
            estimatedTime: 30, // Default value in minutes
            distance: 0.5 // Default value in km
        )
        
        // Check for duplicates before inserting
        let duplicateCheck = busInfos.first { existingBusInfo in
            normalizePlateForComparison(existingBusInfo.plateNumber) == normalizePlateForComparison(plateNumber)
        }
        
        if duplicateCheck == nil {
            modelContext.insert(busInfo)
            
            // Try to save changes
            do {
                try modelContext.save()
                print("Added predefined bus info for plate: \(plateNumber)")
            } catch {
                print("Error adding predefined bus info: \(error.localizedDescription)")
            }
        } else {
            print("Duplicate check caught a potential duplicate entry")
        }
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
        case "teal": return Color(red: 0/255, green: 128/255, blue: 128/255)  // Added teal color
        case "black": return Color(red: 128/255, green: 128/255, blue: 128/255)
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
    
    // Replace the onAppear block with a more reliable async loading function
    private func loadData() async {
        // Set loading state
        isLoading = true
        
        // Debug print to check what's happening
        print("Scanned plate: \(plateNumber)")
        print("Normalized plate for comparison: \(normalizePlateForComparison(plateNumber))")
        print("Available bus infos: \(busInfos.count)")
        print("Available routes: \(busRoutes.count)")
        
        // Introduce a short delay to ensure database is ready
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check for matching bus info
        if matchingBusInfo != nil {
            print("Found matching bus info")
            updateLastSeen()
            isLoading = false
        } else {
            // Check if this plate is in the predefined list in DataSeeder
            if isPredefinedPlate(plateNumber) {
                print("Plate is in predefined list but not in database, adding it")
                addPredefinedBusInfo()
                
                // Force a UI refresh after adding the bus info
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                forceRefresh.toggle() // Toggle to force a refresh
                
                // This will trigger a UI refresh
                if matchingBusInfo != nil {
                    print("Successfully added and matched bus info")
                } else {
                    print("Failed to match bus info after adding")
                }
            }
            
            // Ensure we're not stuck in loading state
            isLoading = false
        }
    }
}

struct StationRowButton: View {
    let station: Station
    let isLast: Bool
    let routeColor: Color
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 15) {
                // Station indicator and line
                VStack(spacing: 0) {
                    Circle()
                        .fill(stationColor)
                        .frame(width: 16, height: 16)
                    
                    if !isLast {
                        Rectangle()
                            .fill(routeColor)
                            .frame(width: 2)
                            .frame(height: 40)
                    }
                }
                
                // Station info
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
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
                }
                .padding(.vertical, 5)
                
                Spacer()
                
                // Distance and arrival time
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(calculateStationDistance(index: index))km")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    // Arrival time
                    if let time = station.arrivalTime {
                        Text(timeFormatter.string(from: time))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Calculate a varying distance for each station
    private func calculateStationDistance(index: Int) -> String {
        // Generate distances that increase with each station (0.1, 0.3, 0.6, etc.)
        let distance = 0.1 + (Double(index) * 0.2)
        return String(format: "%.1f", distance)
    }
    
    private var stationColor: Color {
        if station.isPreviousStation {
            return routeColor.opacity(0.5)
        } else if station.isCurrentStation {
            return routeColor
        } else if station.isNextStation {
            return routeColor
        } else {
            return routeColor.opacity(0.7)
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

#Preview {
    ScanResultView(plateNumber: "B 7466 PAA")
        
}
