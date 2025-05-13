import SwiftUI

struct StationCard: View {
   let station: Station
   
   var body: some View {
       VStack(alignment: .leading, spacing: 8) {
           // Station name
           Text(station.name)
               .font(.headline)
               .foregroundColor(.primary)
               .lineLimit(2)
               .frame(width: 150, height: 40, alignment: .leading)
           
           Spacer(minLength: 0)
           
           // Station status
           if station.isCurrentStation {
               HStack {
                   Circle()
                       .fill(Color.green)
                       .frame(width: 8, height: 8)
                   Text("Current Station")
                       .font(.caption)
                       .foregroundColor(.green)
               }
           } else if station.isNextStation {
               HStack {
                   Circle()
                       .fill(Color.blue)
                       .frame(width: 8, height: 8)
                   Text("Next Stop")
                       .font(.caption)
                       .foregroundColor(.blue)
               }
           } else {
               // Empty spacer to maintain consistent height
               Text(" ")
                   .font(.caption)
                   .foregroundColor(.clear)
                   .frame(height: 16)
           }
           
           // Arrival time if available
           if let arrivalTime = station.arrivalTime {
               Text(timeFormatter.string(from: arrivalTime))
                   .font(.caption)
                   .foregroundColor(.secondary)
           } else {
               // Empty spacer to maintain consistent height
               Text(" ")
                   .font(.caption)
                   .foregroundColor(.clear)
           }
       }
       .padding(12)
       .frame(width: 180, height: 100)
       .background(Color(.systemBackground))
       .cornerRadius(12)
       .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
   }
   
   private var timeFormatter: DateFormatter {
       let formatter = DateFormatter()
       formatter.dateFormat = "HH:mm"
       return formatter
   }
}

#Preview {
   StationCard(station: Station(
       name: "The Breeze",
       arrivalTime: Date(),
       isCurrentStation: true,
       isPreviousStation: false,
       isNextStation: false
   ))
}
