import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showTutorial: Bool
    
    var body: some View {
        TutorialContent(onComplete: {
            // Set flag indicating the app has been launched before
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            // Dismiss this view to reveal HomeView
            showTutorial = false
            dismiss()
        })
    }
}

struct TutorialContent: View {
    var onComplete: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            Text("How To Use")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("BLink Bus Scanner")
                .font(.largeTitle)
                .foregroundColor(Color(hex: "a068ff"))
                .padding(.bottom, 20)
                .fontWeight(.semibold)
            
            // Fixed size container for tutorial steps
            VStack(spacing: 16) {
                TutorialStep(
                    number: "1",
                    title: "Give access to our app",
                    description: "Allow camera access to scan bus plates"
                )
                
                TutorialStep(
                    number: "2",
                    title: "Point your Camera at Bus Plate",
                    description: "Position the plate within the scanning frame"
                )
                
                TutorialStep(
                    number: "3",
                    title: "Go to your destination bus stop",
                    description: "Follow the journey information to reach your destination"
                )
                
                TutorialStep(
                    number: "4",
                    title: "Start your journey!",
                    description: "Track your bus journey in real-time"
                )
                
                // Button positioned directly below the steps
                Button(action: {
                    print("Got it button pressed")
                    onComplete()
                }) {
                    Text("Got it")
                        .fontWeight(.medium)
                        .padding()
                        .frame(width: 120, height: 45)
                        .foregroundColor(.white)
                        .background(Color(hex: "a068ff"))
                        .cornerRadius(10)
                }
                .padding(.top, 24) // Add space between last step and button
            }
            .padding(.horizontal)
            
            Spacer() // Push content to the top
        }
        .background(colorScheme == .dark ? Color.black : Color(red: 245/255, green: 245/255, blue: 245/255))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TutorialStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "a068ff"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1) // Ensure title fits on one line
                    .minimumScaleFactor(0.8) // Scale down slightly if needed
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                    .lineLimit(2) // Allow up to 2 lines for description
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Use maximum available width
            
            Spacer(minLength: 0) // Minimize extra spacing
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(minHeight: 100) // Use minHeight instead of fixed height
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TutorialView(showTutorial: .constant(true))
}
