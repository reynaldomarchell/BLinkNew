import ActivityKit
import WidgetKit
import SwiftUI
import Foundation

// Make sure this matches EXACTLY with your app's BusJourneyAttributes
struct BusJourneyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentLocation: String
        var destination: String
        var estimatedTimeRemaining: TimeInterval
        var distanceRemaining: Double
    }
    
    var busPlateNumber: String
    var routeCode: String
    var routeName: String
    var startTime: Date
    var totalDistance: Double // Added for progress calculation
}

struct BLinkWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusJourneyAttributes.self) { context in
            BusJourneyLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.currentLocation)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.destination)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // Progress bar
                        ProgressBarView(
                            progress: calculateProgress(
                                totalDistance: context.attributes.totalDistance,
                                remainingDistance: context.state.distanceRemaining
                            )
                        )
                        .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String(format: "%.1f km", context.state.distanceRemaining))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("Distance")
                                    .font(.caption2)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(Int(context.state.estimatedTimeRemaining / 60)) min")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("Time")
                                    .font(.caption2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } compactLeading: {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
            } compactTrailing: {
                Text("\(Int(context.state.estimatedTimeRemaining / 60)) min")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
            }
            // Use a direct URL with no parameters for simplicity
            .widgetURL(URL(string: "blink://journey/\(context.attributes.busPlateNumber)"))
            // Update the keylineTint to use the shared color constant
            .keylineTint(Color.primaryPurple)
        }
    }
    
    private func calculateProgress(totalDistance: Double, remainingDistance: Double) -> Double {
        // Calculate progress as a percentage (0.0 to 1.0)
        let traveled = totalDistance - remainingDistance
        let progress = traveled / totalDistance
        
        // Ensure progress is between 0 and 1
        return min(max(progress, 0.0), 1.0)
    }
}

struct BusJourneyLiveActivityView: View {
    let context: ActivityViewContext<BusJourneyAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Station names without labels
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.currentLocation)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(context.state.destination)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Progress bar with bus icon
            ProgressBarView(
                progress: calculateProgress(
                    totalDistance: context.attributes.totalDistance,
                    remainingDistance: context.state.distanceRemaining
                )
            )
            .padding(.vertical, 4)
            
            // Distance and time
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatDistance(context.state.distanceRemaining))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(context.state.estimatedTimeRemaining))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        // Update the background color in BusJourneyLiveActivityView
        .background(Color.primaryPurple)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func calculateProgress(totalDistance: Double, remainingDistance: Double) -> Double {
        // Calculate progress as a percentage (0.0 to 1.0)
        let traveled = totalDistance - remainingDistance
        let progress = traveled / totalDistance
        
        // Ensure progress is between 0 and 1
        return min(max(progress, 0.0), 1.0)
    }
    
    private func formatDistance(_ distance: Double) -> String {
        return String(format: "%.1f km", distance)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        return "\(minutes) min"
    }
}

// Progress bar with bus icon
struct ProgressBarView: View {
    let progress: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 8)
                .cornerRadius(4)
            
            // Progress fill
            Rectangle()
                .fill(Color.white)
                .frame(width: max(8, calculateProgressWidth()), height: 8)
                .cornerRadius(4)
            
            // Bus icon that moves with progress
            Image(systemName: "bus.fill")
                .foregroundColor(Color.primaryPurple)
                .background(Circle().fill(Color.white).frame(width: 24, height: 24))
                .offset(x: calculateBusOffset())
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
    
    // Calculate the width of the progress bar
    private func calculateProgressWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let barWidth = screenWidth * 0.8
        return barWidth * CGFloat(progress)
    }
    
    // Calculate the offset for the bus icon
    private func calculateBusOffset() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let barWidth = screenWidth * 0.8
        let iconSize: CGFloat = 40
        let maxOffset = barWidth - iconSize
        return max(0, maxOffset * CGFloat(progress))
    }
}

// Preview providers
extension BusJourneyAttributes {
    fileprivate static var preview: BusJourneyAttributes {
        BusJourneyAttributes(
            busPlateNumber: "B 1234 XYZ",
            routeCode: "GS",
            routeName: "Greenwich - Sektor 1.3 Loop Line",
            startTime: Date(),
            totalDistance: 3.0
        )
    }
}

extension BusJourneyAttributes.ContentState {
    fileprivate static var smiley: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(
            currentLocation: "Greenwich Park",
            destination: "Halte Sektor 1.3",
            estimatedTimeRemaining: 1500,
            distanceRemaining: 2.5
        )
    }
    
    fileprivate static var starEyes: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(
            currentLocation: "AEON Mall",
            destination: "The Breeze",
            estimatedTimeRemaining: 900,
            distanceRemaining: 1.2
        )
    }
}

#Preview("Notification", as: .content, using: BusJourneyAttributes.preview) {
   BLinkWidgetLiveActivity()
} contentStates: {
    BusJourneyAttributes.ContentState.smiley
    BusJourneyAttributes.ContentState.starEyes
}
