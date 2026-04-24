import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } content: {
            TaskListView(store: store)
        } detail: {
            TaskDetailView(store: store)
        }
        .preferredColorScheme(.light)
        .task {
            store.send(.onAppear)
        }
        .confirmationDialog(
            "Delete task?",
            isPresented: Binding(
                get: { store.deleteCandidateID != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.cancelDelete)
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                store.send(.confirmDelete)
            }
            Button("Cancel", role: .cancel) {
                store.send(.cancelDelete)
            }
        } message: {
            Text("This task will be permanently deleted.")
        }
        .alert(
            messageTitle,
            isPresented: Binding(
                get: { store.userMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.dismissMessage)
                    }
                }
            )
        ) {
            Button("OK") {
                store.send(.dismissMessage)
            }
        } message: {
            Text(messageBody)
        }
    }

    private var messageTitle: LocalizedStringKey {
        switch store.userMessage {
        case .titleRequired:
            return "Title is required"
        case .saveFailed:
            return "Could not save changes"
        case nil:
            return ""
        }
    }

    private var messageBody: LocalizedStringKey {
        switch store.userMessage {
        case .titleRequired:
            return "Enter a task title before saving."
        case .saveFailed:
            return "Reloaded local data to keep the task list consistent."
        case nil:
            return ""
        }
    }
}
