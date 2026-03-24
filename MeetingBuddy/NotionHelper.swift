import AppKit

enum NotionHelper {
    static let meetingsPageURL = URL(string: "https://www.notion.so/veotech/30c74c42e046838d8353817cca4f9110?v=2d974c42e0468272adeb8835de4a9d7d")!

    static func openMeetingsPage() {
        NSWorkspace.shared.open(meetingsPageURL)
    }
}
