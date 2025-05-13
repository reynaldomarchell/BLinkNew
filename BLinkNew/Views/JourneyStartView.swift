import SwiftUI
import SwiftData

struct JourneyStartView: View {
    let plateNumber: String
    let onStartJourney: (BusInfo) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Query bus info and routes
    @Query private var busInfos: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    // Find the matching bus info for the scanned plate with improved matching
    private var matchingBusInfo: BusInfo? {
        // Normalize the input plate number for comparison
        let normalizedPlate = normalizePlateForComparison(plateNumber)
        
        // Try to find a match using normalized comparison
        return busInfos.first { busInfo in
            let normalizedBusPlate = normalizePlateForComparison(busInfo.plateNumber)
            return normalizedPlate == normalizedBusPlate
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Are you want to start journey to this destination?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                if let busInfo = matchingBusInfo {
                    // Destination selection
                    VStack(spacing: 16) {
                        HStack {
                            Text("SELECT STOP")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            // Start journey with this destination
                            onStartJourney(busInfo)
                            dismiss()
                        }) {
                            HStack {
                                Text(busInfo.endPoint)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Journey details
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("0.3 km")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("~\(busInfo.estimatedTime) min")
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
                    
                    // Start journey button
                    Button(action: {
                        // Start journey with this destination
                        onStartJourney(busInfo)
                        dismiss()
                    }) {
                        Text("Start Journey")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "a068ff"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
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
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("Start Journey", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    // Function to normalize plate number for comparison
    private func normalizePlateForComparison(_ plate: String) -> String {
        // Remove all spaces, punctuation, and convert to uppercase
        return plate.uppercased().filter { $0.isLetter || $0.isNumber }
    }
}

#Preview {
    JourneyStartView(plateNumber: "B 7566 PAA", onStartJourney: { _ in })
}
