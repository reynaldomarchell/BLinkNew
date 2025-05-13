import SwiftUI
import WidgetKit
import ActivityKit

struct BusJourneyLiveActivityView: View {
    let context: ActivityViewContext<BusJourneyAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("BLink")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(context.attributes.busPlateNumber)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Location")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(context.state.currentLocation)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Destination")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(context.state.destination)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
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
        .background(Color(hex: "6920e1"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func formatDistance(_ distance: Double) -> String {
        return String(format: "%.1f km", distance)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        return "\(minutes) min"
    }
}

@available(iOS 16.1, *)
struct BusJourneyLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusJourneyAttributes.self) { context in
            BusJourneyLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "bus.fill")
                            .foregroundColor(.white)
                        
                        Text(context.state.currentLocation)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text(context.state.destination)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
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
            .widgetURL(URL(string: "blink://journey"))
            .keylineTint(Color(hex: "6920e1"))
        }
    }
}
