import XCTest
@testable import Sivon

final class TaskDomainTests: XCTestCase {
    func testTodayFilterExcludesCompletedAndUndatedTasks() {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date(timeIntervalSinceReferenceDate: 0)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayTask = TodoTask(title: "Today", dueDate: today)
        let completedTodayTask = TodoTask(title: "Done", isCompleted: true, dueDate: today)
        let undatedTask = TodoTask(title: "Inbox")
        let overdueTask = TodoTask(title: "Late", dueDate: yesterday)

        let result = visibleTasks(
            [completedTodayTask, undatedTask, overdueTask, todayTask],
            filter: .today,
            today: today,
            calendar: calendar
        )

        XCTAssertEqual(result.map(\.id), [todayTask.id])
    }

    func testAllFilterSortsIncompleteDueTasksFirst() {
        let now = Date(timeIntervalSinceReferenceDate: 0)
        let calendar = Calendar(identifier: .gregorian)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        let completed = TodoTask(title: "Done", isCompleted: true, dueDate: now)
        let undated = TodoTask(title: "Undated")
        let dueTomorrow = TodoTask(title: "Tomorrow", dueDate: tomorrow)
        let dueToday = TodoTask(title: "Today", dueDate: now)

        let result = visibleTasks(
            [completed, undated, dueTomorrow, dueToday],
            filter: .all,
            today: now,
            calendar: calendar
        )

        XCTAssertEqual(result.map(\.id), [dueToday.id, dueTomorrow.id, undated.id, completed.id])
    }
}
