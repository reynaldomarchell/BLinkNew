import SwiftUI
import SwiftData

// MARK: - Main View
struct ScanResultView: View {
    let plateNumber: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Query bus info and routes
    @Query private var busInfos: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    @State private var showJourneyView = false
    @State private var selectedStation: String?
    @State private var selectedStationIndex: Int?
    @State private var forceRefresh = false
    @State private var isLoading = true
    @State private var retryCount = 0
    @State private var matchedBusInfo: BusInfo? = nil
    @State private var matchedRoute: BusRoute? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                // Content based on loading state
                if isLoading {
                    loadingView
                } else {
                    mainContentView
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showJourneyView) {
            journeyViewIfNeeded
        }
        .task {
            await loadData()
        }
        .id(forceRefresh)
        .onAppear {
            resetSelectionState()
            setupBackupLoading()
        }
        .onDisappear {
            resetSelectionState()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading route information...")
                .foregroundColor(.secondary)
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Header
            routeHeaderView
            
            // Stations list or empty state
            if stations.isEmpty {
                emptyStateView
            } else {
                stationsListView
            }
        }
    }
    
    private var routeHeaderView: some View {
        VStack(spacing: 12) {
            // Top row with plate number and close button
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
                        .padding(8)
                        .background(Color(.systemGray6).opacity(0.5))
                        .clipShape(Circle())
                }
            }
            
            // Bottom row with route code and name
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
                    .lineLimit(2)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
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
    }
    
    private var stationsListView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(stations.enumerated()), id: \.offset) { index, station in
                    createStationRow(station: station, index: index)
                }
            }
            .background(Color(.systemBackground))
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func createStationRow(station: Station, index: Int) -> some View {
        let stationDistance = 0.1 + (Double(index) * 0.2)
        
        StationRowButton(
            station: station,
            isLast: index == stations.count - 1,
            routeColor: colorFromString(routeInfo.color),
            index: index,
            calculatedDistance: stationDistance,
            onTap: {
                handleStationTap(station: station, index: index)
            }
        )
    }
    
    @ViewBuilder
    private var journeyViewIfNeeded: some View {
        if let busInfo = matchingBusInfo {
            createJourneyView(busInfo: busInfo)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleStationTap(station: Station, index: Int) {
        // Store the station data in local variables first
        let stationName = station.name
        let stationIdx = index
        
        // Calculate the distance and time for this station
        let stationDistance = 0.1 + (Double(index) * 0.2)
        let proportion = Double(index + 1) / Double(stations.count)
        let stationTime = Int(Double(matchingBusInfo?.estimatedTime ?? 30) * proportion)
        
        print("Station tapped: \(stationName), index: \(stationIdx)")
        print("Distance: \(stationDistance), Time: \(stationTime)")
        
        // Create a modified busInfo with the selected station as destination
        if let originalBusInfo = matchingBusInfo {
            // Create a copy with the selected station as the destination
            let modifiedBusInfo = BusInfo(
                id: originalBusInfo.id,
                plateNumber: originalBusInfo.plateNumber,
                routeCode: originalBusInfo.routeCode,
                routeName: originalBusInfo.routeName,
                lastSeen: originalBusInfo.lastSeen,
                startPoint: originalBusInfo.startPoint,
                endPoint: stationName, // Use selected station as endpoint
                estimatedTime: stationTime, // Use calculated time
                distance: stationDistance // Use calculated distance
            )
            
            // Update the stored busInfo
            matchedBusInfo = modifiedBusInfo
            
            // Update state variables
            selectedStation = stationName
            selectedStationIndex = stationIdx
            
            // Force a small delay to ensure state is updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showJourneyView = true
            }
        } else {
            // Fallback if no matching busInfo
            selectedStation = stationName
            selectedStationIndex = stationIdx
            showJourneyView = true
        }
    }
    
    private func createJourneyView(busInfo: BusInfo) -> some View {
        // The busInfo already has the correct destination, time, and distance
        return JourneyView(
            busInfo: busInfo,
            initialState: .start,
            selectedStation: selectedStation,
            selectedStationIndex: selectedStationIndex,
            totalStations: stations.count,
            onJourneyComplete: {
                resetSelectionState()
                showJourneyView = false
            }
        )
    }
    
    private func resetSelectionState() {
        selectedStation = nil
        selectedStationIndex = nil
    }
    
    private func setupBackupLoading() {
        if isLoading && retryCount == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.isLoading {
                    print("Backup loading mechanism triggered")
                    self.retryCount += 1
                    Task {
                        await self.loadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Data Properties
    
    private var matchingBusInfo: BusInfo? {
        // Use the stored value if available
        if let stored = matchedBusInfo {
            return stored
        }
        
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
    
    private var busRoute: BusRoute? {
        // Use the stored value if available
        if let stored = matchedRoute {
            return stored
        }
        
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
    
    private var routeInfo: (code: String, name: String, color: String) {
        if let busInfo = matchingBusInfo, let route = busRoute {
            return (busInfo.routeCode, route.routeName, route.color)
        }
        // Fallback if no matching bus info is found
        return ("--", "Unknown Route", "gray")
    }
    
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
    
    // MARK: - Data Loading
    
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
        
        await loadBusInfo()
    }
    
    private func loadBusInfo() async {
        // Check for matching bus info
        if let busInfo = matchingBusInfo {
            print("Found matching bus info")
            matchedBusInfo = busInfo // Store the matched bus info
            
            // Find and store the matching route
            matchedRoute = busRoutes.first { $0.routeCode == busInfo.routeCode }
            
            updateLastSeen()
            isLoading = false
        } else {
            await handleMissingBusInfo()
        }
    }
    
    private func handleMissingBusInfo() async {
        // Check if this plate is in the predefined list in DataSeeder
        if isPredefinedPlate(plateNumber) {
            print("Plate is in predefined list but not in database, adding it")
            addPredefinedBusInfo()
            
            // Force a UI refresh after adding the bus info
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            await findNewlyAddedBusInfo()
        } else if retryCount < 3 {
            // If we haven't found a match and haven't retried too many times, try again
            retryCount += 1
            print("Retry attempt \(retryCount) for plate: \(plateNumber)")
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            await loadData() // Recursive call with retry
            return
        }
        
        // Ensure we're not stuck in loading state
        isLoading = false
    }
    
    private func findNewlyAddedBusInfo() async {
        // Try to find the newly added bus info
        let newBusInfo = busInfos.first { busInfo in
            normalizePlateForComparison(busInfo.plateNumber) == normalizePlateForComparison(plateNumber)
        }
        
        if let newBusInfo = newBusInfo {
            print("Successfully added and matched bus info")
            matchedBusInfo = newBusInfo // Store the matched bus info
            
            // Find and store the matching route
            matchedRoute = busRoutes.first { $0.routeCode == newBusInfo.routeCode }
        } else {
            print("Failed to match bus info after adding")
            
            // Try one more time with a longer delay
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            createManualBusInfo()
        }
        
        forceRefresh.toggle() // Toggle to force a refresh
    }
    
    private func createManualBusInfo() {
        // Create the bus info manually if needed
        if let routeInfo = getRouteInfoForPlate(plateNumber) {
            let manualBusInfo = BusInfo(
                plateNumber: plateNumber,
                routeCode: routeInfo.code,
                routeName: routeInfo.name,
                startPoint: routeInfo.startPoint,
                endPoint: routeInfo.endPoint,
                estimatedTime: 30,
                distance: 0.5
            )
            matchedBusInfo = manualBusInfo
            
            // Create a matching route if needed
            let manualRoute = busRoutes.first { $0.routeCode == routeInfo.code }
            matchedRoute = manualRoute
        }
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
    
    // MARK: - Utility Methods
    
    private func normalizePlateForComparison(_ plate: String) -> String {
        // Remove all spaces, punctuation, and convert to uppercase
        let normalized = plate.uppercased()
            .filter { $0.isLetter || $0.isNumber }
        
        return normalized
    }
    
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

    private func formatPlateForDisplay(_ plate: String) -> String {
        // If the plate already has spaces, return it as is
        if plate.contains(" ") {
            return plate
        }
        
        // Otherwise, format it with spaces
        return formatPlateNumber(plate) ?? plate
    }
    
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
}

// MARK: - Station Row Button
struct StationRowButton: View {
    let station: Station
    let isLast: Bool
    let routeColor: Color
    let index: Int
    let calculatedDistance: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 15) {
                // Station indicator and line
                stationIndicator
                
                // Station info
                stationInfo
                
                Spacer()
                
                // Distance and arrival time
                stationDetails
            }
            .padding(.horizontal, 16)
            // Remove vertical padding to ensure continuous line
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var stationIndicator: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(stationColor)
                .frame(width: 16, height: 16)
            
            if !isLast {
                Rectangle()
                    .fill(routeColor)
                    .frame(width: 2)
                    .frame(height: isLast ? 0 : 50)
            }
        }
        .frame(width: 16)
    }
    
    private var stationInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
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
    }
    
    private var stationDetails: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(String(format: "%.1f", calculatedDistance))km")
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
