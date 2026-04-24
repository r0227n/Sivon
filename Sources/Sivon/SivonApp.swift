import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct SivonApp: App {
    @State private var selectedLanguageRawValue = AppLanguage.current.rawValue

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
                .environment(\.locale, selectedLanguage.locale)
                .id(selectedLanguage.rawValue)
                .frame(minWidth: 1040, minHeight: 680)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)

        Settings {
            SettingsView(selectedLanguageRawValue: selectedLanguageBinding)
                .environment(\.locale, selectedLanguage.locale)
        }
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(storedValue: selectedLanguageRawValue)
    }

    private var selectedLanguageBinding: Binding<String> {
        Binding(
            get: { selectedLanguageRawValue },
            set: { newValue in
                selectedLanguageRawValue = newValue
                UserDefaults.standard.set(newValue, forKey: AppLanguage.storageKey)
            }
        )
    }
}
