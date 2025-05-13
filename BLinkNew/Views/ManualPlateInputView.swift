//
//  ManualPlateInputView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import SwiftData

struct ManualPlateInputView: View {
    @State private var plateNumber = ""
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var busInfos: [BusInfo]
    var onSelectBus: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select The \nBus Plate Number")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            
                // Use a wheel picker for bus plates
                Picker("Bus Plate Number", selection: $plateNumber) {
                    Text("Select a plate").tag("")
                    ForEach(busInfos, id: \.plateNumber) { busInfo in
                        Text(formatPlateForDisplay(busInfo.plateNumber)).tag(busInfo.plateNumber)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
                Button(action: {
                    if !plateNumber.isEmpty {
                        // Call the callback with the selected plate
                        onSelectBus(plateNumber)
                    }
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(plateNumber.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(plateNumber.isEmpty)
            
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .onAppear {
            // Debug print to check available bus infos
            print("Available bus plates in picker: \(busInfos.map { $0.plateNumber }.joined(separator: ", "))")
        }
    }
    
    // Add the formatPlateForDisplay function
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
    // For the preview to work with SwiftData, you need to provide a model container
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: BusInfo.self, configurations: config)
        
        // Add some sample data for the preview
        let sampleBusInfo = BusInfo(plateNumber: "B 1234 XYZ", routeCode: "BC", routeName: "Sample Route")
        container.mainContext.insert(sampleBusInfo)
        
        return ManualPlateInputView(onSelectBus: { _ in })
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
