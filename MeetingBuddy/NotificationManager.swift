import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    init() {
        requestPermission()
        registerCategories()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    private func registerCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_NOTION",
            title: "Open Notion",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "MEETING_REMINDER",
            actions: [openAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func sendMeetingReminder(meeting: Meeting) {
        let content = UNMutableNotificationContent()
        content.title = "Meeting Starting"
        content.body = "\(meeting.title) — tap to open Notion for transcription"
        content.sound = .default
        content.categoryIdentifier = "MEETING_REMINDER"

        let request = UNNotificationRequest(
            identifier: "meeting-\(meeting.id)",
            content: content,
            trigger: nil // Fire immediately
        )

        UNUserNotificationCenter.current().add(request)
    }
}
