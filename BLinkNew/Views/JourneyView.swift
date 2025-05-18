import SwiftUI
import SwiftData

enum JourneyState {
    case start
    case ongoing
    case completed
}

struct JourneyView: View {
    let busInfo: BusInfo
    let onJourneyComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var journeyState: JourneyState
    @State private var remainingTime: Int
    @State private var remainingDistance: Double
    @State private var timer: Timer?
    @State private var showCompletionAlert = false
    @State private var selectedStation: String?
    @State private var selectedStationIndex: Int?
    @State private var totalStations: Int
    @State private var isEndingJourney = false
    @State private var destinationStation: String
    
    init(busInfo: BusInfo, initialState: JourneyState = .start, selectedStation: String? = nil, selectedStationIndex: Int? = nil, totalStations: Int = 0, stationDistance: Double? = nil, stationTime: Int? = nil, onJourneyComplete: @escaping () -> Void) {
        self.busInfo = busInfo
        self.onJourneyComplete = onJourneyComplete
        self.selectedStation = selectedStation
        self.selectedStationIndex = selectedStationIndex
        self.totalStations = totalStations
        
        // Always use the busInfo.endPoint as the destination
        _destinationStation = State(initialValue: busInfo.endPoint)
        _journeyState = State(initialValue: initialState)
        
        // Use the values from the busInfo directly, which should already have the correct values
        _remainingDistance = State(initialValue: busInfo.distance)
        _remainingTime = State(initialValue: busInfo.estimatedTime)
        
        print("JourneyView initialized with destination: \(busInfo.endPoint)")
        print("Distance: \(busInfo.distance), Time: \(busInfo.estimatedTime)")
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    // Header text changes based on state
                    if journeyState == .start {
                        Text("Are you ready to start journey to \(destinationStation)?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                    }
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Destination card
                            destinationCard
                                .padding(.horizontal)
                                .padding(.top, journeyState == .start ? 0 : 20)
                            
                            // Journey details (only shown in start and ongoing states)
                            if journeyState != .completed {
                                journeyDetails
                                    .padding(.horizontal)
                            }
                            
                            // Middle content changes based on state
                            if journeyState == .completed {
                                completionContent
                                    .padding(.top, 40)
                            }
                            
                            // Add spacer to push content to the top
                            Spacer(minLength: geometry.size.height * 0.2)
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom button changes based on state
                    actionButton
                        .padding(.horizontal)
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
                        .padding(.top, 16)
                }
                .navigationBarTitle(navigationTitle, displayMode: .inline)
                .navigationBarItems(leading: Button("Back") {
                    if journeyState == .completed {
                        dismiss()
                        onJourneyComplete()
                    } else {
                        dismiss()
                    }
                })
                .onAppear {
                    if journeyState == .ongoing {
                        startJourneyTimer()
                    }
                    
                    // Print debug info
                    print("JourneyView appeared with state: \(journeyState)")
                    print("Destination: \(destinationStation)")
                    print("Remaining time: \(remainingTime) minutes")
                    print("Remaining distance: \(remainingDistance) km")
                    print("BusInfo endpoint: \(busInfo.endPoint)")
                    
                    if let station = selectedStation {
                        print("Selected station: \(station)")
                    } else {
                        print("No specific station selected, using end point: \(busInfo.endPoint)")
                    }
                    
                    if let index = selectedStationIndex {
                        print("Selected station index: \(index) of \(totalStations)")
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
                .alert(isPresented: $showCompletionAlert) {
                    Alert(
                        title: Text("End Journey"),
                        message: Text("Are you sure you want to end your journey?"),
                        primaryButton: .default(Text("Yes"), action: {
                            endJourney()
                        }),
                        secondaryButton: .cancel()
                    )
                }
                .overlay(
                    Group {
                        if isEndingJourney {
                            Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                                .overlay(
                                    VStack {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .padding()
                                        Text("Ending journey...")
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - View Components
    
    private var navigationTitle: String {
        switch journeyState {
        case .start:
            return "Start Journey"
        case .ongoing:
            return "Current Journey"
        case .completed:
            return "Journey Complete"
        }
    }
    
    private var destinationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(formatPlateForDisplay(busInfo.plateNumber))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(destinationStation)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(routeCodeColor)
                        .frame(width: 60, height: 60)
                    
                    Text(busInfo.routeCode)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color(.systemBackground).cornerRadius(16))
        )
    }
    
    private var journeyDetails: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f км", remainingDistance))
                    .font(.system(size: 28, weight: .bold))
                
                Text("Distance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 60)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Est. \(formatTime(remainingTime))")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
    }
    
    private var completionContent: some View {
        VStack(spacing: 24) {
            Text("You have arrived at \(destinationStation) 🎉")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding(.top, 20)
        }
        .padding()
    }
    
    private var actionButton: some View {
        Button(action: {
            switch journeyState {
            case .start:
                startJourney()
            case .ongoing:
                showCompletionAlert = true
            case .completed:
                dismiss()
                onJourneyComplete()
            }
        }) {
            Text(buttonText)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isEndingJourney)
    }
    
    private var buttonText: String {
        switch journeyState {
        case .start:
            return "Start Journey!"
        case .ongoing:
            return "Stop Journey"
        case .completed:
            return "Got it!"
        }
    }
    
    private var buttonColor: Color {
        switch journeyState {
        case .start, .completed:
            return Color(hex: "a068ff")
        case .ongoing:
            return Color.red
        }
    }
    
    // MARK: - Helper Methods
    
    private func startJourney() {
        journeyState = .ongoing
        startJourneyTimer()
        
        // Start live activity with the correct destination
        LiveActivityManager.shared.startBusJourney(
            busInfo: busInfo,
            destination: destinationStation // This will be the selected station
        )
        
        print("Started journey to: \(destinationStation)")
    }
    
    private func startJourneyTimer() {
        // Start a timer to update the remaining time and distance
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            updateJourneyProgress()
        }
    }
    
    private func updateJourneyProgress() {
        // Simulate journey progress by decreasing time and distance
        if remainingTime > 0 {
            remainingTime -= 1
        }
        
        if remainingDistance > 0 {
            // Calculate distance reduction based on total distance and time
            let distancePerMinute = busInfo.distance / Double(busInfo.estimatedTime)
            remainingDistance = max(0, remainingDistance - distancePerMinute)
        }
        
        // If journey is complete, show completion view
        if remainingTime <= 0 || remainingDistance <= 0 {
            timer?.invalidate()
            timer = nil
            
            // Show journey completion view
            withAnimation {
                journeyState = .completed
            }
            
            // End the live activity
            LiveActivityManager.shared.endBusJourney()
        } else {
            // Update the live activity - use current location directly without prefix
            LiveActivityManager.shared.updateBusJourney(
                currentLocation: busInfo.startPoint,
                timeRemaining: TimeInterval(remainingTime * 60),
                distanceRemaining: remainingDistance
            )
        }
    }
    
    private func endJourney() {
        // Show loading overlay
        isEndingJourney = true
        
        // Stop the timer first
        timer?.invalidate()
        timer = nil
        
        // End the live activity and wait for completion
        Task {
            // End the live activity and wait for it to complete
            await LiveActivityManager.shared.endBusJourneyAsync()
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Show completion state
                withAnimation {
                    journeyState = .completed
                    isEndingJourney = false
                }
            }
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private func formatPlateForDisplay(_ plate: String) -> String {
        // If the plate already has spaces, return it as is
        if plate.contains(" ") {
            return plate
        }
        
        // Otherwise, try to format it with spaces
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
        
        return plate
    }
    
    private var routeCodeColor: Color {
        switch busInfo.routeCode {
        case "BC":
            return .purple
        case "GS":
            return .green
        case "AS":
            return Color(red: 34/255, green: 139/255, blue: 34/255)
        case "ID1":
            return Color(red: 64/255, green: 224/255, blue: 208/255)
        case "ID2":
            return Color(red: 219/255, green: 112/255, blue: 147/255)
        case "IV":
            return Color(red: 154/255, green: 205/255, blue: 50/255)
        case "IS":
            return .orange  // Changed from teal to orange
        case "EC":
            return Color(red: 0/255, green: 128/255, blue: 128/255)  // Changed to teal
        default:
            return .blue
        }
    }
}

#Preview {
    JourneyView(
        busInfo: BusInfo(
            plateNumber: "B 1234 XYZ",
            routeCode: "GS",
            routeName: "Greenwich - Sektor 1.3 Loop Line",
            startPoint: "Greenwich Park",
            endPoint: "Vanya Park",
            estimatedTime: 25,
            distance: 0.3
        ),
        initialState: .start,
        onJourneyComplete: {}
    )
}
