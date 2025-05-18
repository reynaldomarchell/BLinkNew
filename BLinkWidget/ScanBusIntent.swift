import AppIntents
import SwiftUI

struct ScanBusIntent: AppIntent {
    static var title: LocalizedStringResource = "Scan Bus"
    static var description = IntentDescription("Open BLink to scan a bus plate")
    
    static var openAppWhenRun = true
    
    // Make this intent searchable in Spotlight
    static var searchKeywords: [String] = [
        "bus", "scan", "plate", "blink", "transport", "journey", "BSD", "route"
    ]
    
    func perform() async throws -> some IntentResult {
        // This will open the app at the HomeView
        return .result()
    }
    
    // Add support for suggested phrases that Siri can recognize
    static var parameterSummary: some ParameterSummary {
        Summary("Scan a bus plate")
    }
}

// Make the intent discoverable in Spotlight and Siri
extension ScanBusIntent {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        return TypeDisplayRepresentation(name: "Scan Bus")
    }
    
    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "Scan Bus Plate",
            subtitle: "Open BLink camera to scan a bus plate",
            image: .init(systemName: "bus.fill")
        )
    }
}

// Removed the ScanBusShortcut struct since we're now using BLinkApp as the AppShortcutsProvider
