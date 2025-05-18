import SwiftUI
import SwiftData

struct ManualPlateInputView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var busInfos: [BusInfo]
    var onSelectBus: (String) -> Void
    
    // Filtered buses based on search text
    private var filteredBuses: [BusInfo] {
        if searchText.isEmpty {
            return busInfos
        } else {
            // Normalize the search text for comparison
            let normalizedSearch = searchText.uppercased().filter { $0.isLetter || $0.isNumber }
            
            return busInfos.filter { busInfo in
                // Normalize the plate number for comparison
                let normalizedPlate = busInfo.plateNumber.uppercased().filter { $0.isLetter || $0.isNumber }
                return normalizedPlate.contains(normalizedSearch)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar with "B |" prefix
                HStack(spacing: 0) {
                    Text("B | ")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "a068ff"))
                    
                    TextField("1234", text: $searchText)
                        .font(.system(size: 18))
                        .disableAutocorrection(true)
                        .autocapitalization(.allCharacters)
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "a068ff").opacity(0.7))
                                .padding(.trailing, 8)
                        }
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "a068ff"))
                            .padding(.trailing, 8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "a068ff"), lineWidth: 2)
                        .shadow(color: Color(hex: "a068ff").opacity(0.5), radius: 3, x: 0, y: 0)
                )
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Results list
                if filteredBuses.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bus.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No matching plates found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Try a different plate number")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredBuses) { busInfo in
                                Button(action: {
                                    onSelectBus(busInfo.plateNumber)
                                    dismiss()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formatPlateForDisplay(busInfo.plateNumber))
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(busInfo.routeName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                }
                                
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Manual Input", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    // Format a plate number in the standard format: B 1234 XYZ
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

#Preview {
    ManualPlateInputView(onSelectBus: { _ in })
}
