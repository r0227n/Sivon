import ComposableArchitecture
import SwiftUI

struct TaskListView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            listHeader
            newTaskField

            HStack(spacing: 8) {
                selectedFilterTitle
                    .font(.system(size: 15, weight: .semibold))
                Text("\(store.visibleTasks.count)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.sivonPrimary.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.sivonPrimary)
                Spacer()
            }

            if store.visibleTasks.isEmpty {
                emptyList
            } else {
                List {
                    ForEach(store.visibleTasks) { task in
                        TaskRowView(task: task, store: store)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(24)
        .background(Color.sivonSurface)
        .navigationSplitViewColumnWidth(min: 390, ideal: 470, max: 560)
    }

    private var listHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            selectedFilterTitle
                .font(.system(size: 22, weight: .semibold))
            Text(Date.now, format: .dateTime.year().month(.wide).day().weekday(.wide))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private var newTaskField: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .foregroundStyle(.secondary)
            TextField("Add a task...", text: $store.newTaskTitle)
                .textFieldStyle(.plain)
                .onSubmit {
                    store.send(.createTaskSubmitted)
                }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .stroke(Color.sivonBorder)
        )
    }

    private var emptyList: some View {
        ContentUnavailableView {
            Label("No tasks", systemImage: "checkmark.circle")
        } description: {
            Text("Add a task or switch views.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var selectedFilterTitle: some View {
        switch store.selectedFilter {
        case .today:
            Text("Today")
        case .all:
            Text("All Tasks")
        case .overdue:
            Text("Overdue")
        case .completed:
            Text("Completed")
        }
    }
}

private struct TaskRowView: View {
    let task: TodoTask
    @Bindable var store: StoreOf<AppFeature>

    private var isOverdue: Bool {
        isTaskOverdue(task)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.send(.toggleCompletion(task.id))
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        task.isCompleted ? Color.sivonSuccess : Color.sivonSecondaryText)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark incomplete" : "Mark complete")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(task.isCompleted ? Color.sivonSecondaryText : Color.sivonText)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    dueDateText
                }
                .font(.system(size: 12))
                .foregroundStyle(isOverdue ? Color.sivonDanger : Color.sivonSecondaryText)
            }

            Spacer()

            Menu {
                rescheduleButtons
                Divider()
                Button("Delete", role: .destructive) {
                    store.send(.requestDelete(task.id))
                }
            } label: {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 15, weight: .medium))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.sivonSelection : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isOverdue ? Color.sivonDanger.opacity(0.25) : Color.sivonBorder)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            store.send(.selectTask(task.id))
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .contextMenu {
            rescheduleButtons
            Divider()
            Button("Delete", role: .destructive) {
                store.send(.requestDelete(task.id))
            }
        }
    }

    private var isSelected: Bool {
        task.id == store.selectedTaskID
    }

    @ViewBuilder
    private var dueDateText: some View {
        if let dueDate = task.dueDate {
            Text(dueDate, style: .date)
        } else {
            Text("No date")
        }
    }

    @ViewBuilder
    private var rescheduleButtons: some View {
        Button("Today") {
            store.send(.setDueDate(task.id, .today))
        }
        Button("Tomorrow") {
            store.send(.setDueDate(task.id, .tomorrow))
        }
        Button("Next Week") {
            store.send(.setDueDate(task.id, .nextWeek))
        }
        Button("No Date") {
            store.send(.setDueDate(task.id, .none))
        }
    }
}
