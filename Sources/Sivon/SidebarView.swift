import ComposableArchitecture
import SwiftUI

struct SidebarView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.square")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Sivon")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.top, 18)

            List(selection: $store.selectedFilter) {
                Section {
                    ForEach(TaskFilter.allCases) { filter in
                        Label {
                            HStack {
                                filterTitle(filter)
                                Spacer()
                                Text("\(count(for: filter))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: filter.systemImage)
                        }
                        .tag(filter)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.sidebar)

            Spacer()

            SettingsLink {
                Label("Settings", systemImage: "gearshape")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .background(Color.sivonBackground)
        .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
    }

    @ViewBuilder
    private func filterTitle(_ filter: TaskFilter) -> some View {
        switch filter {
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

    private func count(for filter: TaskFilter) -> Int {
        visibleTasks(store.tasks, filter: filter).count
    }
}
