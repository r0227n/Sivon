import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct SivonApp: App {
    private let modelContainer: ModelContainer
    private let store: StoreOf<AppFeature>

    init() {
        do {
            let container = try ModelContainer(for: PersistedTask.self)
            self.modelContainer = container
            self.store = Store(initialState: AppFeature.State()) {
                AppFeature(taskPersistence: .live(modelContext: container.mainContext))
            }
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .modelContainer(modelContainer)
                .frame(minWidth: 1040, minHeight: 680)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
