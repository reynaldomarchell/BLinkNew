import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var recentBuses: [BusInfo]
    
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var onSelectBus: (String) -> Void
    
    var filteredBuses: [BusInfo] {
        if searchText.isEmpty {
            return recentBuses
        } else {
            return recentBuses.filter { busInfo in
                busInfo.plateNumber.localizedCaseInsensitiveContains(searchText) ||
                busInfo.routeName.localizedCaseInsensitiveContains(searchText) ||
                busInfo.routeCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(.primary)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Tab selector
                Picker("History Type", selection: $selectedTab) {
                    Text("History").tag(0)
                    Text("Saved Routes").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
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
                                                HistoryRouteCodeBadge(routeCode: busInfo.routeCode)
                                                
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
                } else {
                    // Saved routes (placeholder for now)
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Saved Routes")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Your favorite routes will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
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
    
    var body: some View {
        Text(routeCode)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(routeCodeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(routeCodeColor.opacity(0.2))
            .cornerRadius(4)
    }
    
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
            return Color(red: 0/255, green: 128/255, blue: 128/255)
        default:
            return .blue
        }
    }
}

#Preview {
    HistoryView(onSelectBus: { _ in })
}
