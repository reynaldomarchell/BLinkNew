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
    
    init(busInfo: BusInfo, initialState: JourneyState = .start, onJourneyComplete: @escaping () -> Void) {
        self.busInfo = busInfo
        self.onJourneyComplete = onJourneyComplete
        _journeyState = State(initialValue: initialState)
        _remainingTime = State(initialValue: busInfo.estimatedTime)
        _remainingDistance = State(initialValue: busInfo.distance)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header text changes based on state
                Text(headerText)
                    .font(.headline)
                    .padding(.top, 20)
                
                // Destination card
                VStack(spacing: 16) {
                    // Bus plate and destination card
                    destinationCard
                    
                    // Journey details (only shown in start and ongoing states)
                    if journeyState != .completed {
                        journeyDetails
                    }
                }
                .padding(.horizontal)
                
                // Middle content changes based on state
                if journeyState == .completed {
                    completionContent
                }
                
                Spacer()
                
                // Bottom button changes based on state
                actionButton
            }
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                dismiss()
            })
            .onAppear {
                if journeyState == .ongoing {
                    startJourneyTimer()
                }
            }
            .onDisappear {
                timer?.invalidate()
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
        }
    }
    
    // MARK: - View Components
    
    private var headerText: String {
        switch journeyState {
        case .start:
            return "Are you want to start journey to this destination?"
        case .ongoing, .completed:
            return "Your current journey"
        }
    }
    
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
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formatPlateForDisplay(busInfo.plateNumber))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(busInfo.endPoint)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(routeCodeColor)
                            .frame(width: 40, height: 40)
                        
                        Text(busInfo.routeCode)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color(.systemBackground).cornerRadius(12))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var journeyDetails: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f км", remainingDistance))
                    .font(.title2)
                    .fontWeight(.bold)
                
                if journeyState == .start {
                    Spacer().frame(height: 20)
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 40)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Est. \(formatTime(remainingTime))")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if journeyState == .start {
                    Spacer().frame(height: 20)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var completionContent: some View {
        VStack(spacing: 16) {
            Text("You have arrived at your destination 🎉")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
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
        .padding(.horizontal)
        .padding(.bottom, 20)
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
        
        // Start live activity
        LiveActivityManager.shared.startBusJourney(
            busInfo: busInfo,
            destination: busInfo.endPoint
        )
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
            
            // Show journey completion view
            withAnimation {
                journeyState = .completed
            }
            
            // End the live activity
            LiveActivityManager.shared.endBusJourney()
        } else {
            // Update the live activity
            LiveActivityManager.shared.updateBusJourney(
                currentLocation: "En route to \(busInfo.endPoint)",
                timeRemaining: TimeInterval(remainingTime * 60),
                distanceRemaining: remainingDistance
            )
        }
    }
    
    private func endJourney() {
        timer?.invalidate()
        
        // End the live activity
        LiveActivityManager.shared.endBusJourney()
        
        // Show completion state
        withAnimation {
            journeyState = .completed
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
        let cleaned = plate.uppercased()
        
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
