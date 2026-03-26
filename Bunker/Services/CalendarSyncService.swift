import Foundation
import EventKit

/// R5: Calendar integration for decision deadlines
final class CalendarSyncService: @unchecked Sendable {
    static let shared = CalendarSyncService()

    private let eventStore = EKEventStore()
    private let calendarIdentifierKey = "bunker_calendar_id"

    private init() {}

    // MARK: - Authorization

    func requestAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            eventStore.requestAccess(to: .event) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    var isAuthorized: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    // MARK: - Calendar Management

    private func bunkerCalendar() -> EKCalendar? {
        if let identifier = UserDefaults.standard.string(forKey: calendarIdentifierKey),
           let calendar = eventStore.calendar(withIdentifier: identifier) {
            return calendar
        }

        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = "Bunker Decisions"

        if let source = eventStore.sources.first(where: { $0.sourceType == .local }) ?? eventStore.sources.first {
            calendar.source = source
            do {
                try eventStore.saveCalendar(calendar, commit: true)
                UserDefaults.standard.set(calendar.calendarIdentifier, forKey: calendarIdentifierKey)
                return calendar
            } catch {
                return nil
            }
        }
        return nil
    }

    // MARK: - Add Deadline Event

    func addDeadlineEvent(for decision: Decision) async -> String? {
        if !isAuthorized {
            let granted = await requestAccess()
            if !granted { return nil }
        }

        guard let calendar = bunkerCalendar(),
              let deadline = decision.deadlineDate else { return nil }

        let event = EKEvent(eventStore: eventStore)
        event.title = "Decision Due: \(decision.title)"
        event.notes = """
        Bunker Decision: \(decision.title)

        \(decision.description.isEmpty ? "No description" : decision.description)

        \(decision.criteria.count) criteria, \(decision.options.count) options

        Open Bunker to decide.
        """
        event.startDate = deadline
        event.endDate = deadline.addingTimeInterval(3600)
        event.calendar = calendar
        event.isAllDay = true

        let alarm = EKAlarm(relativeOffset: -86400)
        event.addAlarm(alarm)

        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }

    // MARK: - Remove Event

    func removeEvent(identifier: String) {
        guard let event = eventStore.event(withIdentifier: identifier) else { return }
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            print("CalendarSyncService: failed to remove event: \(error)")
        }
    }

    // MARK: - Update Event

    func updateDeadlineEvent(identifier: String, newDate: Date?, newTitle: String) {
        guard let event = eventStore.event(withIdentifier: identifier) else { return }

        if let newDate = newDate {
            event.startDate = newDate
            event.endDate = newDate.addingTimeInterval(3600)
            event.isAllDay = true
        }
        event.title = "Decision Due: \(newTitle)"

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            print("CalendarSyncService: failed to save event: \(error)")
        }
    }

    // MARK: - Sync All Decisions

    func syncAllDecisions(_ decisions: [Decision]) async {
        for decision in decisions {
            if decision.deadlineDate != nil {
                _ = await addDeadlineEvent(for: decision)
            }
        }
    }
}
