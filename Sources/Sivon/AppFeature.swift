import ComposableArchitecture
import Foundation

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var tasks: [TodoTask] = []
        var selectedFilter: TaskFilter = .today
        var selectedTaskID: TodoTask.ID?
        var newTaskTitle = ""
        var deleteCandidateID: TodoTask.ID?
        var userMessage: UserMessage?

        var visibleTasks: [TodoTask] {
            Sivon.visibleTasks(tasks, filter: selectedFilter)
        }

        var selectedTask: TodoTask? {
            guard let selectedTaskID else { return nil }
            return tasks.first { $0.id == selectedTaskID }
        }

        func count(for filter: TaskFilter) -> Int {
            Sivon.visibleTasks(tasks, filter: filter).count
        }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case tasksLoaded([TodoTask])
        case createTaskSubmitted
        case selectTask(TodoTask.ID?)
        case toggleCompletion(TodoTask.ID)
        case updateTitle(TodoTask.ID, String)
        case updateNotes(TodoTask.ID, String)
        case setDueDate(TodoTask.ID, DueDateChoice)
        case requestDelete(TodoTask.ID)
        case cancelDelete
        case confirmDelete
        case dismissMessage
        case persistenceFailed
    }

    private let taskPersistence: TaskPersistenceClient

    init(taskPersistence: TaskPersistenceClient = .noop) {
        self.taskPersistence = taskPersistence
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .run { send in
                    do {
                        let tasks = try await taskPersistence.fetchAll()
                        await send(.tasksLoaded(tasks))
                    } catch {
                        await send(.persistenceFailed)
                    }
                }

            case let .tasksLoaded(tasks):
                state.tasks = tasks
                if let selectedTaskID = state.selectedTaskID,
                   !state.tasks.contains(where: { $0.id == selectedTaskID }) {
                    state.selectedTaskID = nil
                }
                return .none

            case .createTaskSubmitted:
                let trimmedTitle = state.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedTitle.isEmpty else {
                    state.userMessage = .titleRequired
                    return .none
                }

                let now = Date()
                let dueDate = state.selectedFilter == .today ? Calendar.current.startOfDay(for: now) : nil
                let task = TodoTask(title: trimmedTitle, dueDate: dueDate, createdAt: now)

                state.tasks.append(task)
                state.selectedTaskID = task.id
                state.newTaskTitle = ""
                state.userMessage = nil
                return persist(task)

            case let .selectTask(id):
                state.selectedTaskID = id
                return .none

            case let .toggleCompletion(id):
                guard let index = state.tasks.firstIndex(where: { $0.id == id }) else { return .none }
                var task = state.tasks[index]
                task.isCompleted.toggle()
                task.updatedAt = Date()
                state.tasks[index] = task
                return persist(task)

            case let .updateTitle(id, title):
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedTitle.isEmpty else {
                    state.userMessage = .titleRequired
                    return .none
                }
                guard let index = state.tasks.firstIndex(where: { $0.id == id }) else { return .none }
                var task = state.tasks[index]
                guard task.title != trimmedTitle else { return .none }
                task.title = trimmedTitle
                task.updatedAt = Date()
                state.tasks[index] = task
                state.userMessage = nil
                return persist(task)

            case let .updateNotes(id, notes):
                guard let index = state.tasks.firstIndex(where: { $0.id == id }) else { return .none }
                var task = state.tasks[index]
                guard task.notes != notes else { return .none }
                task.notes = notes
                task.updatedAt = Date()
                state.tasks[index] = task
                return persist(task)

            case let .setDueDate(id, choice):
                guard let index = state.tasks.firstIndex(where: { $0.id == id }) else { return .none }
                var task = state.tasks[index]
                task.dueDate = choice.date(relativeTo: Date(), calendar: .current)
                task.updatedAt = Date()
                state.tasks[index] = task
                return persist(task)

            case let .requestDelete(id):
                state.deleteCandidateID = id
                return .none

            case .cancelDelete:
                state.deleteCandidateID = nil
                return .none

            case .confirmDelete:
                guard let id = state.deleteCandidateID else { return .none }
                state.tasks.removeAll { $0.id == id }
                if state.selectedTaskID == id {
                    state.selectedTaskID = nil
                }
                state.deleteCandidateID = nil
                return .run { send in
                    do {
                        try await taskPersistence.delete(id)
                    } catch {
                        await send(.persistenceFailed)
                        await send(.onAppear)
                    }
                }

            case .dismissMessage:
                state.userMessage = nil
                return .none

            case .persistenceFailed:
                state.userMessage = .saveFailed
                return .none
            }
        }
    }

    private func persist(_ task: TodoTask) -> Effect<Action> {
        .run { send in
            do {
                try await taskPersistence.upsert(task)
            } catch {
                await send(.persistenceFailed)
                await send(.onAppear)
            }
        }
    }
}
