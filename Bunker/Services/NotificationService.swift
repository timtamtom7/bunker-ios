import Foundation
import UserNotifications

/// R6: Enhanced notification service with custom sounds and smart reminders
final class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        } catch {
            return false
        }
    }

    var isAuthorized: Bool {
        get async {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        }
    }

    // MARK: - Schedule Decision Reminder

    func scheduleDecisionReminder(for decision: Decision, remindBefore: TimeInterval = 86400) async {
        guard let deadline = decision.deadlineDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Decision Due Tomorrow"
        content.body = "\"\(decision.title)\" has a deadline tomorrow. Time to make your call."
        content.sound = .default
        content.categoryIdentifier = "DECISION_REMINDER"
        content.userInfo = ["decisionId": decision.id.uuidString]

        let reminderDate = deadline.addingTimeInterval(-remindBefore)
        guard reminderDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "decision_reminder_\(decision.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Schedule Resolution Reminder

    func scheduleResolutionReminder(for decision: Decision) async {
        guard let deadline = decision.deadlineDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Decision Deadline Passed"
        content.body = "How did you decide on \"\(decision.title)\"? Record the outcome to learn from it."
        content.sound = .default
        content.categoryIdentifier = "DECISION_RESOLUTION"
        content.userInfo = ["decisionId": decision.id.uuidString]

        let triggerDate = deadline.addingTimeInterval(3600) // 1 hour after deadline
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "decision_resolution_\(decision.id.uuidString)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Weekly Summary

    func scheduleWeeklySummary() async {
        let content = UNMutableNotificationContent()
        content.title = "Your Week in Decisions"
        content.body = "Tap to see your decision activity and insights from this week."
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"

        // Schedule for Saturday 10am
        var components = DateComponents()
        components.weekday = 7  // Saturday
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel Notifications

    func cancelNotifications(for decisionId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "decision_reminder_\(decisionId.uuidString)",
            "decision_resolution_\(decisionId.uuidString)"
        ])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Notification Categories

    func registerCategories() {
        let markDoneAction = UNNotificationAction(
            identifier: "MARK_DONE",
            title: "Mark Decided",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind in 1 Hour",
            options: []
        )

        let decisionCategory = UNNotificationCategory(
            identifier: "DECISION_REMINDER",
            actions: [markDoneAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        let resolutionCategory = UNNotificationCategory(
            identifier: "DECISION_RESOLUTION",
            actions: [markDoneAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([decisionCategory, resolutionCategory])
    }
}
