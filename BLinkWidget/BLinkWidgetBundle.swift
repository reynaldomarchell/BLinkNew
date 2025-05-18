import WidgetKit
import SwiftUI

@main
struct BLinkWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Only include the Live Activity widget
        BLinkWidgetLiveActivity()
    }
}
