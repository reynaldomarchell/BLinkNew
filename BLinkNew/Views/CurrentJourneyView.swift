import SwiftUI
import SwiftData

struct CurrentJourneyView: View {
    let busInfo: BusInfo
    let onJourneyComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var remainingTime: Int
    @State private var remainingDistance: Double
    @State private var timer: Timer?
    @State private var showCompletionAlert = false
    
    init(busInfo: BusInfo, onJourneyComplete: @escaping () -> Void) {
        self.busInfo = busInfo
        self.onJourneyComplete = onJourneyComplete
        _remainingTime = State(initialValue: busInfo.estimatedTime)
        _remainingDistance = State(initialValue: busInfo.distance)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your current journey")
                    .font(.headline)
                    .padding(.top, 20)
                
                // Destination card
                VStack(spacing: 16) {
                    HStack {
                        Text("DESTINATION")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(busInfo.endPoint)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Journey details
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: "%.1f km", remainingDistance))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("~\(remainingTime) min")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // End journey button
                Button(action: {
                    showCompletionAlert = true
                }) {
                    Text("End Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "a068ff"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Current Journey", displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                dismiss()
            })
            .onAppear {
                // Start a timer to update the remaining time and distance
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                    updateJourneyProgress()
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
            dismiss()
            onJourneyComplete()
            
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
        
        // Dismiss the view and notify parent
        dismiss()
        onJourneyComplete()
    }
}

#Preview {
    CurrentJourneyView(
        busInfo: BusInfo(
            plateNumber: "B 7566 PAA",
            routeCode: "GS",
            routeName: "Greenwich - Sektor 1.3 Loop Line",
            startPoint: "Greenwich Park",
            endPoint: "Vanya Park",
            estimatedTime: 25,
            distance: 0.3
        ),
        onJourneyComplete: {}
    )
}
