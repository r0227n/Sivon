import Foundation
import SwiftData

@Model
final class PersistedTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(task: TodoTask) {
        self.id = task.id
        self.title = task.title
        self.notes = task.notes
        self.isCompleted = task.isCompleted
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
    }

    var domainValue: TodoTask {
        TodoTask(
            id: id,
            title: title,
            notes: notes,
            isCompleted: isCompleted,
            dueDate: dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func update(from task: TodoTask) {
        title = task.title
        notes = task.notes
        isCompleted = task.isCompleted
        dueDate = task.dueDate
        createdAt = task.createdAt
        updatedAt = task.updatedAt
    }
}

struct TaskPersistenceClient: Sendable {
    var fetchAll: @Sendable () async throws -> [TodoTask]
    var upsert: @Sendable (TodoTask) async throws -> Void
    var delete: @Sendable (TodoTask.ID) async throws -> Void

    static let noop = Self(
        fetchAll: { [] },
        upsert: { _ in },
        delete: { _ in }
    )
}

extension TaskPersistenceClient {
    @MainActor
    static func live(modelContext: ModelContext) -> Self {
        let repository = SwiftDataTaskRepository(modelContext: modelContext)
        return Self(
            fetchAll: {
                try await MainActor.run {
                    try repository.fetchAll()
                }
            },
            upsert: { task in
                try await MainActor.run {
                    try repository.upsert(task)
                }
            },
            delete: { id in
                try await MainActor.run {
                    try repository.delete(id)
                }
            }
        )
    }
}

@MainActor
private final class SwiftDataTaskRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [TodoTask] {
        let descriptor = FetchDescriptor<PersistedTask>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .forward)
            ]
        )
        return try modelContext.fetch(descriptor).map(\.domainValue)
    }

    func upsert(_ task: TodoTask) throws {
        let taskID = task.id
        let descriptor = FetchDescriptor<PersistedTask>(
            predicate: #Predicate { persistedTask in
                persistedTask.id == taskID
            }
        )

        if let persistedTask = try modelContext.fetch(descriptor).first {
            persistedTask.update(from: task)
        } else {
            modelContext.insert(PersistedTask(task: task))
        }

        try modelContext.save()
    }

    func delete(_ id: TodoTask.ID) throws {
        let descriptor = FetchDescriptor<PersistedTask>(
            predicate: #Predicate { persistedTask in
                persistedTask.id == id
            }
        )

        for task in try modelContext.fetch(descriptor) {
            modelContext.delete(task)
        }

        try modelContext.save()
    }
}
