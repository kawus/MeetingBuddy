import SwiftUI
import UserNotifications

@main
struct MeetingBuddyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        MenuBarExtra {
            MeetingMenuView(calendarManager: calendarManager)
        } label: {
            MenuBarLabel(calendarManager: calendarManager)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var calendarManager: CalendarManager

    var body: some View {
        let hasLive = !calendarManager.liveMeetings.isEmpty
        Image(systemName: hasLive ? "record.circle.fill" : "mic.circle")
            .symbolRenderingMode(.palette)
            .foregroundStyle(hasLive ? Color.red : Color.primary)
            .font(.system(size: 16))
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "OPEN_NOTION" ||
            response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            NotionHelper.openMeetingsPage()
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
