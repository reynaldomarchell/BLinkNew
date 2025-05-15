import SwiftUI
import SwiftData

enum SortOrder {
    case newest
    case oldest
    case alphabetical
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var recentBuses: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .newest
    
    var onSelectBus: (String) -> Void
    
    var filteredBuses: [BusInfo] {
        let filtered = searchText.isEmpty ? recentBuses : recentBuses.filter { busInfo in
            busInfo.plateNumber.localizedCaseInsensitiveContains(searchText) ||
            busInfo.routeName.localizedCaseInsensitiveContains(searchText) ||
            busInfo.routeCode.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOrder {
        case .newest:
            return filtered.sorted { $0.lastSeen > $1.lastSeen }
        case .oldest:
            return filtered.sorted { $0.lastSeen < $1.lastSeen }
        case .alphabetical:
            return filtered.sorted { $0.plateNumber < $1.plateNumber }
        }
    }
    
    // Helper function to get route color for a route code
    private func getRouteColor(for routeCode: String) -> String {
        if let route = busRoutes.first(where: { $0.routeCode == routeCode }) {
            return route.color
        }
        
        // Fallback mapping if route not found
        switch routeCode {
        case "BC": return "purple"
        case "GS": return "green"
        case "AS": return "darkgreen"
        case "ID1": return "lightblue"
        case "ID2": return "pink"
        case "IV": return "darkgreen"
        case "IS": return "orange"  // Changed from navy to orange
        case "EC": return "teal"    // Changed from red to teal
        default: return "blue"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Combined search bar with filter button
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Menu {
                        Button(action: { sortOrder = .newest }) {
                            Label("Newest First", systemImage: "arrow.down.to.line")
                        }
                        
                        Button(action: { sortOrder = .oldest }) {
                            Label("Oldest First", systemImage: "arrow.up.to.line")
                        }
                        
                        Button(action: { sortOrder = .alphabetical }) {
                            Label("Alphabetical", systemImage: "textformat.abc")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                            .frame(width: 38, height: 38)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // History list
                if filteredBuses.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "clock.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No History Yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Your scanned bus plates will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredBuses) { busInfo in
                            Button(action: {
                                onSelectBus(busInfo.plateNumber)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formatPlateForDisplay(busInfo.plateNumber))
                                            .font(.headline)
                                        
                                        HStack {
                                            HistoryRouteCodeBadge(
                                                routeCode: busInfo.routeCode,
                                                colorName: getRouteColor(for: busInfo.routeCode)
                                            )
                                            
                                            Text(busInfo.routeName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(timeAgo(date: busInfo.lastSeen))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onDelete(perform: deleteBusInfo)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitle("History", displayMode: .inline)
            .navigationBarItems(
                leading: EditButton().disabled(filteredBuses.isEmpty),
                trailing: Button("Close") {
                    dismiss()
                }
            )
        }
    }
    
    private var sortOrderLabel: String {
        switch sortOrder {
        case .newest:
            return "Newest First"
        case .oldest:
            return "Oldest First"
        case .alphabetical:
            return "Alphabetical"
        }
    }
    
    private func timeAgo(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func deleteBusInfo(at offsets: IndexSet) {
        for index in offsets {
            let busInfo = filteredBuses[index]
            modelContext.delete(busInfo)
        }
        
        // Try to save changes
        do {
            try modelContext.save()
            print("Successfully deleted bus info")
        } catch {
            print("Error deleting bus info: \(error.localizedDescription)")
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
}

struct HistoryRouteCodeBadge: View {
    let routeCode: String
    let colorName: String
    
    var body: some View {
        Text(routeCode)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(colorFromString(colorName))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(colorFromString(colorName).opacity(0.2))
            .cornerRadius(4)
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
        case "teal": return .teal
        case "black": return Color(red: 128/255, green: 128/255, blue: 128/255)
        default: return .gray
        }
    }
}

#Preview {
    HistoryView(onSelectBus: { _ in })
}
