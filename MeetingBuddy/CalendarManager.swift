import EventKit
import SwiftUI
import Combine

struct Meeting: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool

    var isLive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var isUpcoming: Bool {
        Date() < startDate
    }

    var isPast: Bool {
        Date() > endDate
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }

    var minutesUntilStart: Int {
        Int(startDate.timeIntervalSinceNow / 60)
    }
}

class CalendarManager: ObservableObject {
    private let store = EKEventStore()
    @Published var meetings: [Meeting] = []
    @Published var hasAccess = false
    @Published var autoOpen = true
    @Published var reminderMinutes = 1

    private var refreshTimer: Timer?
    private var notifiedMeetingIDs: Set<String> = []
    private var openedMeetingIDs: Set<String> = []

    var nextMeeting: Meeting? {
        meetings.first { $0.isUpcoming || $0.isLive }
    }

    var liveMeetings: [Meeting] {
        meetings.filter { $0.isLive }
    }

    var upcomingMeetings: [Meeting] {
        meetings.filter { $0.isUpcoming }
    }

    var pastMeetings: [Meeting] {
        meetings.filter { $0.isPast }
    }

    init() {
        requestAccess()
        startRefreshTimer()
    }

    func requestAccess() {
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.fetchTodaysMeetings()
                    }
                }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.fetchTodaysMeetings()
                    }
                }
            }
        }
    }

    func fetchTodaysMeetings() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = store.events(matching: predicate)

        DispatchQueue.main.async {
            self.meetings = events
                .filter { !$0.isAllDay }
                .map { event in
                    Meeting(
                        id: event.eventIdentifier,
                        title: event.title ?? "Untitled Meeting",
                        startDate: event.startDate,
                        endDate: event.endDate,
                        isAllDay: event.isAllDay
                    )
                }
                .sorted { $0.startDate < $1.startDate }

            self.checkForUpcomingMeetings()
        }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchTodaysMeetings()
        }
    }

    private func checkForUpcomingMeetings() {
        for meeting in meetings {
            let minutes = meeting.minutesUntilStart

            // Send notification at reminder time
            if minutes <= reminderMinutes && minutes >= 0 && !notifiedMeetingIDs.contains(meeting.id) {
                notifiedMeetingIDs.insert(meeting.id)
                NotificationManager.shared.sendMeetingReminder(meeting: meeting)
            }

            // Auto-open Notion when meeting starts
            if autoOpen && minutes <= 0 && meeting.isLive && !openedMeetingIDs.contains(meeting.id) {
                openedMeetingIDs.insert(meeting.id)
                NotionHelper.openMeetingsPage()
            }
        }
    }

    func resetForNewDay() {
        notifiedMeetingIDs.removeAll()
        openedMeetingIDs.removeAll()
        fetchTodaysMeetings()
    }
}
