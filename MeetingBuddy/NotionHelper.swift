import AppKit

enum NotionHelper {
    static let meetingsPageURL = URL(string: "https://www.notion.so/meet")!

    static func openMeetingsPage() {
        NSWorkspace.shared.open(meetingsPageURL)
    }
}
