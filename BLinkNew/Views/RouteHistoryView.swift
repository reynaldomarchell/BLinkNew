//
//  RouteHistoryView.swift
//  BLink
//
//  Created by reynaldo on 06/04/25.
//

import SwiftUI
import SwiftData

struct RouteHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var recentBuses: [BusInfo]
    
    var onSelectBus: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recently Scanned Buses")) {
                    if recentBuses.isEmpty {
                        Text("No recent bus scans")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(recentBuses) { busInfo in
                            Button(action: {
                                onSelectBus(busInfo.plateNumber)
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formatPlateForDisplay(busInfo.plateNumber))
                                            .font(.headline)
                                        
                                        HStack {
                                            RouteCodeBadge(routeCode: busInfo.routeCode)
                                            
                                            Text(busInfo.routeName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
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
                }
            }
            .navigationBarTitle("Bus History", displayMode: .inline)
            .navigationBarItems(
                leading: EditButton(),
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
            let busInfo = recentBuses[index]
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

struct RouteCodeBadge: View {
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
            return Color(red: 0/255, green: 128/255, blue: 128/255) // Added teal color for IS route
        default:
            return .blue
        }
    }
}

#Preview {
    RouteHistoryView(onSelectBus: { _ in })
}
