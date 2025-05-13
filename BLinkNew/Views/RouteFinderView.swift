import SwiftUI
import SwiftData

struct RouteFinderView: View {
   @State private var destination = ""
   @State private var selectedRoute: BusRoute?
   @StateObject private var locationManager = LocationManager()
   @State private var customLocation = ""
   @State private var isLoading = false
   @Environment(\.modelContext) private var modelContext
   @Environment(\.dismiss) private var dismiss
   
   // Query all bus routes - use a simple descriptor without filters
   @State private var routes: [BusRoute] = []
   @Query private var busInfos: [BusInfo]
   
   // State for route history
   @State private var showRouteHistory = false
   
   // Filtered routes based on destination search
   private var filteredRoutes: [BusRoute] {
       if destination.isEmpty && customLocation.isEmpty {
           return routes
       } else {
           return routes.filter { route in
               let matchesDestination = destination.isEmpty ||
                   route.routeName.localizedCaseInsensitiveContains(destination) ||
                   route.endPoint.localizedCaseInsensitiveContains(destination) ||
                   route.stations.contains { station in
                       station.name.localizedCaseInsensitiveContains(destination)
                   }
               
               let matchesLocation = customLocation.isEmpty ||
                   route.startPoint.localizedCaseInsensitiveContains(customLocation)
               
               return matchesDestination && matchesLocation
           }
       }
   }
   

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Unified input section
                HStack(alignment: .top, spacing: 12) {
                    // Icon column
                    VStack(spacing: 6) {
                        Image(systemName: "figure.stand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.gray)
                            .cornerRadius(4)

                        VStack(spacing: 2) {
                            ForEach(0..<4) { _ in
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 2, height: 2)
                            }
                        }

                        Image(systemName: "mappin.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }

                    VStack(spacing: 12) {
                        // Top: Current location input
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your Location")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                TextField("Enter your location", text: $customLocation)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding(6)
                            } else {
                                Button(action: {
                                    // Swap location and destination
                                    let tempLocation = customLocation
                                    customLocation = destination
                                    destination = tempLocation
                                }) {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .foregroundColor(.red)
                                        .padding(6)
                                        .background(Circle().stroke(Color.yellow, lineWidth: 2))
                                }
                            }
                        }

                        Divider()

                        // Bottom: Destination input
                        TextField("Where you want to go?", text: $destination)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 16) // Add top padding to align at the top
                
                // Recommendations section with history button
                HStack {
                    Text("Recommendations")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                    
                    Button(action: {
                        showRouteHistory = true
                    }) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray6)))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                if filteredRoutes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No routes found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Try a different destination")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredRoutes) { route in
                                RouteRecommendationCard(
                                    from: route.startPoint,
                                    to: route.endPoint,
                                    routeCode: route.routeCode,
                                    routeDescription: route.routeDescription ?? "\(route.startPoint) → \(route.endPoint)",
                                    duration: route.estimatedTime,
                                    distance: route.distance,
                                    onTap: {
                                        selectedRoute = route
                                    }
                                )
                                .id(route.id) // Add explicit ID to ensure proper updates
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 0) // Add spacer to push content to the top
            }
            .navigationBarTitle("Route Finder", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
                
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            })
            .onAppear {
                // Pre-load location data
                if locationManager.currentAddress.isEmpty {
                    locationManager.requestLocation()
                }
                
                // Manually fetch routes to ensure they're loaded
                fetchRoutes()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: Binding(
            get: { selectedRoute != nil },
            set: { if !$0 { selectedRoute = nil } }
        )) {
            if let route = selectedRoute {
                RouteResultView(route: route)
            }
        }
        .sheet(isPresented: $showRouteHistory) {
            RouteHistoryView(onSelectBus: { plateNumber in
                // Find the route for this bus
                if let busInfo = busInfos.first(where: { $0.plateNumber == plateNumber }),
                   let route = routes.first(where: { $0.routeCode == busInfo.routeCode }) {
                    selectedRoute = route
                }
            })
        }
    }
    
    private func fetchRoutes() {
        do {
            let descriptor = FetchDescriptor<BusRoute>()
            routes = try modelContext.fetch(descriptor)
            print("Manually fetched \(routes.count) routes")
            
            // If no routes found, try to seed them
            if routes.isEmpty {
                print("No routes found in manual fetch, attempting to seed")
                DataSeeder.seedInitialData(modelContext: modelContext)
                
                // Try fetching again
                routes = try modelContext.fetch(descriptor)
                print("After seeding, found \(routes.count) routes")
                
                // If still empty, create routes directly
                if routes.isEmpty {
                    print("Still no routes, creating directly")
                    createDefaultRoutes()
                    routes = try modelContext.fetch(descriptor)
                    print("After direct creation, found \(routes.count) routes")
                }
            }
            
            // Debug output
            for route in routes {
                print("Route: \(route.routeName), Code: \(route.routeCode)")
            }
        } catch {
            print("Error fetching routes: \(error)")
        }
    }
    
    private func createDefaultRoutes() {
        // Create BC route
        let bcRoute = BusRoute(
            routeName: "The Breeze - AEON - ICE - The Breeze Loop Line",
            startPoint: "The Breeze",
            endPoint: "The Breeze",
            stations: [
                Station(name: "The Breeze"),
                Station(name: "CBD Timur 1"),
                Station(name: "CBD Selatan"),
                Station(name: "AEON Mall 1"),
                Station(name: "AEON Mall 2")
            ],
            routeCode: "BC",
            color: "purple",
            estimatedTime: 65,
            distance: 6.9,
            routeDescription: "The Breeze → AEON → ICE → The Breeze Loop Line"
        )
        
        // Create GS route
        let gsRoute = BusRoute(
            routeName: "Greenwich - Sektor 1.3 Loop Line",
            startPoint: "Greenwich Park",
            endPoint: "Halte Sektor 1.3",
            stations: [
                Station(name: "Greenwich Park"),
                Station(name: "CBD Timur 1"),
                Station(name: "CBD Selatan"),
                Station(name: "AEON Mall 1"),
                Station(name: "AEON Mall 2")
            ],
            routeCode: "GS",
            color: "green",
            estimatedTime: 65,
            distance: 6.9,
            routeDescription: "Greenwich - Sektor 1.3 Loop Line"
        )
        
        // Insert routes
        modelContext.insert(bcRoute)
        modelContext.insert(gsRoute)
        
        print("Created default routes directly")
    }
}

struct RouteRecommendationCard: View {
   let from: String
   let to: String
   let routeCode: String
   let routeDescription: String
   let duration: Int
   let distance: Double
   let onTap: () -> Void
   
   var body: some View {
       Button(action: onTap) {
           VStack(alignment: .leading, spacing: 10) {
               // Route title
               HStack {
                   Text(from)
                       .foregroundColor(.blue)
                   
                   Image(systemName: "arrow.right")
                       .foregroundColor(.secondary)
                   
                   Text(to)
                       .foregroundColor(.blue)
               }
               .font(.headline)
               
               // Route details
               HStack {
                   ZStack {
                       Capsule()
                           .fill(routeCodeColor.opacity(0.2))
                           .frame(width: 36, height: 24)
                       
                       Text(routeCode)
                           .font(.caption)
                           .fontWeight(.bold)
                           .foregroundColor(routeCodeColor)
                   }
                   
                   Text(routeDescription)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
               }
               
               // Duration and distance
               HStack(spacing: 20) {
                   Label("\(duration) Minutes", systemImage: "clock")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                   
                   Label("\(String(format: "%.1f", distance)) Km", systemImage: "figure.walk")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
               }
           }
           .padding()
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color(.systemBackground))
           .cornerRadius(12)
           .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
       }
       .buttonStyle(PlainButtonStyle())
   }
   
   // Get color based on route code
   private var routeCodeColor: Color {
       switch routeCode {
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
           return Color(red: 0/255, green: 128/255, blue: 128/255) // Added teal color for IS route
       default:
           return .blue
       }
   }
}

#Preview {
   RouteFinderView()
}
