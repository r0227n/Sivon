import Foundation
import SwiftUI

struct TodoTask: Equatable, Identifiable, Codable {
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }
}

enum TaskFilter: String, CaseIterable, Equatable, Identifiable {
    case today
    case all
    case overdue
    case completed

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .today:
            "sun.max"
        case .all:
            "tray.full"
        case .overdue:
            "clock.badge.exclamationmark"
        case .completed:
            "checkmark"
        }
    }

    func includes(_ task: TodoTask, today: Date, calendar: Calendar) -> Bool {
        switch self {
        case .today:
            guard let dueDate = task.dueDate else { return false }
            return !task.isCompleted && calendar.isDate(dueDate, inSameDayAs: today)
        case .all:
            return true
        case .overdue:
            guard let dueDate = task.dueDate else { return false }
            return !task.isCompleted && calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: today)
        case .completed:
            return task.isCompleted
        }
    }

    func sort(_ lhs: TodoTask, _ rhs: TodoTask) -> Bool {
        switch self {
        case .today, .overdue:
            return compareByDueDateThenCreatedAt(lhs, rhs)
        case .all:
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }
            return compareByDueDateThenCreatedAt(lhs, rhs)
        case .completed:
            return lhs.updatedAt > rhs.updatedAt
        }
    }
}

enum DueDateChoice: Equatable {
    case today
    case tomorrow
    case nextWeek
    case custom(Date)
    case none

    func date(relativeTo baseDate: Date, calendar: Calendar) -> Date? {
        switch self {
        case .today:
            return calendar.startOfDay(for: baseDate)
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: baseDate))
        case .nextWeek:
            return calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: baseDate))
        case let .custom(date):
            return calendar.startOfDay(for: date)
        case .none:
            return nil
        }
    }
}

enum UserMessage: Equatable {
    case titleRequired
    case saveFailed
}

func visibleTasks(
    _ tasks: [TodoTask],
    filter: TaskFilter,
    today: Date = Date(),
    calendar: Calendar = .current
) -> [TodoTask] {
    tasks
        .filter { filter.includes($0, today: today, calendar: calendar) }
        .sorted(by: filter.sort)
}

func isTaskOverdue(_ task: TodoTask, today: Date = Date(), calendar: Calendar = .current) -> Bool {
    guard let dueDate = task.dueDate, !task.isCompleted else { return false }
    return calendar.startOfDay(for: dueDate) < calendar.startOfDay(for: today)
}

private func compareByDueDateThenCreatedAt(_ lhs: TodoTask, _ rhs: TodoTask) -> Bool {
    switch (lhs.dueDate, rhs.dueDate) {
    case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
        return lhsDate < rhsDate
    case (nil, _?):
        return false
    case (_?, nil):
        return true
    default:
        return lhs.createdAt < rhs.createdAt
    }
}
