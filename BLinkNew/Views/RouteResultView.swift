//
//  RouteResultView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import MapKit
import SwiftData

struct RouteResultView: View {
  let route: BusRoute
  
  @Environment(\.dismiss) private var dismiss
  @State private var showAlert = false
  @State private var showEnlargedMap = false
  @State private var mapScale: CGFloat = 1.0
  @State private var mapOffset: CGSize = .zero
  @State private var lastDragValue: CGSize = .zero
  @StateObject private var locationManager = LocationManager()
  @Environment(\.modelContext) private var modelContext
  
  // Start station coordinates (simulated for now - in a real app, you'd get this from the route)
  private let startStationCoordinates = CLLocationCoordinate2D(latitude: -6.298, longitude: 106.648)
  
  var body: some View {
      ZStack {
          // Main content
          NavigationView {
              ScrollView {
                  VStack(spacing: 12) {
                      // Location and destination display
                      VStack(spacing: 8) {
                          // Origin location
                          HStack(spacing: 12) {
                              VStack(spacing: 0) {
                                  Circle()
                                      .fill(Color.green)
                                      .frame(width: 10, height: 10)
                                  
                                  Rectangle()
                                      .fill(Color.gray.opacity(0.5))
                                      .frame(width: 2, height: 24)
                              }
                              
                              VStack(alignment: .leading, spacing: 2) {
                                  Text("Your Location")
                                      .font(.caption)
                                      .foregroundColor(.secondary)
                                  
                                  Text(locationManager.currentAddress.isEmpty ? "Current Location" : locationManager.currentAddress)
                                      .font(.subheadline)
                              }
                              
                              Spacer()
                          }
                          
                          // Destination
                          HStack(spacing: 12) {
                              Circle()
                                  .fill(Color.orange)
                                  .frame(width: 10, height: 10)
                              
                              VStack(alignment: .leading, spacing: 2) {
                                  Text("Your Destination")
                                      .font(.caption)
                                      .foregroundColor(.secondary)
                                  
                                  Text(route.endPoint)
                                      .font(.subheadline)
                              }
                              
                              Spacer()
                          }
                      }
                      .padding(.horizontal, 16)
                      .padding(.vertical, 12)
                      .background(Color(.systemBackground))
                      .cornerRadius(12)
                      .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                      .padding(.horizontal, 16)
                      .padding(.top, 8)
                      
                      // Route Details section
                      VStack(alignment: .leading, spacing: 12) {
                          Text("Route Details")
                              .font(.title3)
                              .fontWeight(.bold)
                              .padding(.horizontal, 16)
                              .padding(.top, 4)
                          
                          // Route recommendation
                          CompactRouteCard(
                              from: route.startPoint,
                              to: route.endPoint,
                              routeCode: route.routeCode,
                              duration: route.estimatedTime,
                              distance: route.distance,
                              routeDescription: route.routeDescription ?? "\(route.startPoint) → \(route.endPoint)"
                          )
                          .padding(.horizontal, 16)
                          
                          // Stations list
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Stations")
                                  .font(.headline)
                                  .padding(.horizontal, 16)
                                  .padding(.top, 4)
                              
                              ScrollView(.horizontal, showsIndicators: false) {
                                  HStack(spacing: 12) {
                                      ForEach(Array(route.stations.enumerated()), id: \.offset) { index, station in
                                          StationCard(station: station)
                                      }
                                  }
                                  .padding(.horizontal, 16)
                                  .padding(.vertical, 4)
                              }
                          }
                          
                          // Static Route Map Image
                          VStack(alignment: .leading, spacing: 8) {
                              Text("Route Map")
                                  .font(.headline)
                                  .padding(.horizontal, 16)
                                  .padding(.top, 4)
                              
                              VStack(spacing: 16) {
                                  // Display static route map image based on route code
                                  routeMapImage
                                      .resizable()
                                      .aspectRatio(contentMode: .fit)
                                      .frame(maxWidth: .infinity)
                                      .cornerRadius(12)
                                      .padding(.horizontal, 16)
                                      .onTapGesture {
                                          showEnlargedMap = true
                                          mapScale = 1.0 // Reset scale when opening
                                          mapOffset = .zero // Reset offset when opening
                                          lastDragValue = .zero
                                      }
                                  
                                  Button(action: {
                                      openMapsDirections()
                                  }) {
                                      Text("Go to Bus Stop")
                                          .font(.headline)
                                          .foregroundColor(.white)
                                          .frame(maxWidth: .infinity)
                                          .frame(height: 44)
                                          .background(Color.blue)
                                          .cornerRadius(10)
                                  }
                                  .padding(.horizontal, 32)
                                  .padding(.bottom, 16)
                              }
                          }
                      }
                  }
                  .padding(.bottom, 16)
              }
              .navigationBarTitle("Route Result", displayMode: .inline)
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
                  // Request location when view appears
                  if locationManager.currentAddress.isEmpty {
                      locationManager.requestLocation()
                  }
                  
                  // Update station statuses based on current time
                  DataSeeder.updateStationStatus(route: route)
              }
          }
          .navigationViewStyle(StackNavigationViewStyle())
          .alert(isPresented: $showAlert) {
              Alert(
                  title: Text("Could Not Open Maps"),
                  message: Text("There was a problem opening Maps to get directions to the bus stop."),
                  dismissButton: .default(Text("OK"))
              )
          }
          
          // Enlarged map overlay
          if showEnlargedMap {
              ZStack {
                  // Semi-transparent background that can be tapped to dismiss
                  Color.black.opacity(0.7)
                      .edgesIgnoringSafeArea(.all)
                      .onTapGesture {
                          showEnlargedMap = false
                      }
                  
                  // Map image with zoom and pan gestures
                  ZoomableScrollView(scale: $mapScale, offset: $mapOffset) {
                      routeMapImage
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(maxWidth: .infinity, maxHeight: .infinity)
                          .padding(.horizontal, 20)
                  }
              }
              .zIndex(2)
              .transition(.opacity)
          }
      }
      .animation(.easeInOut, value: showEnlargedMap)
  }
  
  // Get the appropriate route map image based on route code
  private var routeMapImage: Image {
      switch route.routeCode {
      case "BC":
          return Image("bcLine")
      case "GS":
          return Image("gsLine")
      case "ID1":
          return Image("id1Line")
      case "IV":
          return Image("ivLine")
      case "IS":
          return Image("id1Line")
      case "ID2":
          return Image("id1Line")
      case "EC":
          return Image("id1Line")
      case "BB":
          return Image("id1Line")
      default:
          // Fallback to a placeholder for other routes - must return Image type without modifiers
          return Image(systemName: "map")
      }
  }
  
  private func openMapsDirections() {
      // Still directing to the start station
      let placemark = MKPlacemark(coordinate: startStationCoordinates)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = route.startPoint
      
      let launchOptions = [
          MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
      ]
      
      if !mapItem.openInMaps(launchOptions: launchOptions) {
          showAlert = true
      }
  }
}

// Custom zoomable scroll view for smooth zooming and panning
struct ZoomableScrollView<Content: View>: View {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @State private var dragOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            content()
                .scaleEffect(scale)
                .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            
                            // Limit scale to reasonable bounds
                            let newScale = scale * delta
                            scale = min(max(newScale, 0.5), 5.0)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow panning when zoomed in
                            if scale > 1.0 {
                                // Apply smooth drag with appropriate sensitivity
                                dragOffset = value.translation
                            }
                        }
                        .onEnded { value in
                            // Update the final offset
                            if scale > 1.0 {
                                // Calculate max allowed offset based on zoom level
                                let maxOffsetX = geometry.size.width * (scale - 1) / 2
                                let maxOffsetY = geometry.size.height * (scale - 1) / 2
                                
                                // Calculate new offset with constraints
                                let newOffsetX = offset.width + value.translation.width
                                let newOffsetY = offset.height + value.translation.height
                                
                                // Apply constraints to keep image on screen
                                offset = CGSize(
                                    width: min(maxOffsetX, max(-maxOffsetX, newOffsetX)),
                                    height: min(maxOffsetY, max(-maxOffsetY, newOffsetY))
                                )
                                
                                // Reset drag offset
                                dragOffset = .zero
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        scale = 1.0
                        offset = .zero
                        dragOffset = .zero
                    }
                }
        }
    }
}

// More compact route card for smaller screens
struct CompactRouteCard: View {
    let from: String
    let to: String
    let routeCode: String
    let duration: Int
    let distance: Double
    let routeDescription: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Route title
            HStack {
                Text(from)
                    .foregroundColor(.blue)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(to)
                    .foregroundColor(.blue)
            }
            .font(.subheadline)
            
            // Route details
            HStack {
                ZStack {
                    Capsule()
                        .fill(routeCodeColor.opacity(0.2))
                        .frame(width: 32, height: 22)
                    
                    Text(routeCode)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(routeCodeColor)
                }
                
                Text(routeDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Duration and distance
            HStack(spacing: 16) {
                Label("\(duration) Minutes", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(String(format: "%.1f", distance)) Km", systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
  // Create a sample route for preview
  let stations = [
      Station(name: "Greenwich Park", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false),
      Station(name: "CBD Barat", arrivalTime: nil, isCurrentStation: true, isPreviousStation: false, isNextStation: false),
      Station(name: "CBD Timur", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: true),
      Station(name: "Lobby AEON Mall", arrivalTime: nil, isCurrentStation: false, isPreviousStation: false, isNextStation: false)
  ]
  
  let sampleRoute = BusRoute(
      routeName: "Greenwich Park - Halte Sektor 1.3",
      startPoint: "Greenwich Park",
      endPoint: "Halte Sektor 1.3",
      stations: stations,
      routeCode: "GS",
      color: "green",
      estimatedTime: 65,
      distance: 6.9,
      routeDescription: "Greenwich - Sektor 1.3 Loop Line"
  )
  
  return RouteResultView(route: sampleRoute)
}
