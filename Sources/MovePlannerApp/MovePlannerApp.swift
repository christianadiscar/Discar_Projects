import SwiftUI

@main
struct MovePlannerApp: App {
    @State private var store = ProjectStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
