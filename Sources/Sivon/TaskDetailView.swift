import ComposableArchitecture
import SwiftUI

struct TaskDetailView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        Group {
            if let task = store.selectedTask {
                detail(for: task)
            } else {
                ContentUnavailableView {
                    Label("Select a task", systemImage: "sidebar.right")
                } description: {
                    Text("Choose a task from the list or create a new one.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(28)
        .background(Color.white)
        .navigationSplitViewColumnWidth(min: 360, ideal: 480, max: 620)
    }

    private func detail(for task: TodoTask) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Button {
                    store.send(.toggleCompletion(task.id))
                } label: {
                    Label(
                        task.isCompleted ? "Completed" : "Incomplete",
                        systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(.borderless)

                Spacer()

                Button(role: .destructive) {
                    store.send(.requestDelete(task.id))
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Delete")
            }

            TextField(
                "Task title",
                text: Binding(
                    get: { task.title },
                    set: { store.send(.updateTitle(task.id, $0)) }
                )
            )
            .textFieldStyle(.plain)
            .font(.system(size: 24, weight: .semibold))

            VStack(spacing: 0) {
                detailRow(systemImage: "calendar", title: "Due Date") {
                    DatePicker(
                        "Due Date",
                        selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { store.send(.setDueDate(task.id, .custom($0))) }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }

                Divider()

                detailRow(systemImage: "checklist", title: "Status") {
                    Toggle(
                        task.isCompleted ? "Completed" : "Incomplete",
                        isOn: Binding(
                            get: { task.isCompleted },
                            set: { _ in store.send(.toggleCompletion(task.id)) }
                        )
                    )
                    .toggleStyle(.switch)
                }
            }
            .background(Color.sivonBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sivonBorder)
            )

            VStack(alignment: .leading, spacing: 8) {
                Label("Notes", systemImage: "note.text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.sivonSecondaryText)

                TextEditor(
                    text: Binding(
                        get: { task.notes },
                        set: { store.send(.updateNotes(task.id, $0)) }
                    )
                )
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.sivonBackground, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.sivonBorder)
                )
                .frame(minHeight: 180)
            }

            Spacer()
        }
    }

    private func detailRow<Content: View>(
        systemImage: String,
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14))
                .foregroundStyle(Color.sivonSecondaryText)
                .frame(width: 150, alignment: .leading)
            content()
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
