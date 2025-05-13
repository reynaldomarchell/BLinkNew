import SwiftUI

struct JourneyCompletionView: View {
    let destination: String
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your current journey")
                .font(.headline)
                .padding(.top, 20)
            
            // Destination card
            VStack(spacing: 16) {
                HStack {
                    Text("DESTINATION")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    Text(destination)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Completion message
            VStack(spacing: 16) {
                Text("You have arrived at your destination 🎉")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            .padding()
            
            Spacer()
            
            // Done button
            Button(action: {
                dismiss()
                onDismiss()
            }) {
                Text("Got it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "a068ff"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationBarTitle("Journey Complete", displayMode: .inline)
        .navigationBarItems(leading: Button("Back") {
            dismiss()
            onDismiss()
        })
    }
}

#Preview {
    JourneyCompletionView(destination: "Vanya Park", onDismiss: {})
}
