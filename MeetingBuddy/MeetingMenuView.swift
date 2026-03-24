import SwiftUI

struct MeetingMenuView: View {
    @ObservedObject var calendarManager: CalendarManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("MeetingBuddy")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Toggle("Auto-open", isOn: $calendarManager.autoOpen)
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            if !calendarManager.hasAccess {
                noAccessView
            } else if calendarManager.meetings.isEmpty {
                emptyView
            } else {
                meetingsList
            }

            Divider()

            // Footer
            HStack {
                Button("Open Notion") {
                    NotionHelper.openMeetingsPage()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
    }

    private var noAccessView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.title)
                .foregroundColor(.secondary)
            Text("Calendar access needed")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Open Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.title)
                .foregroundColor(.secondary)
            Text("No meetings today")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }

    private var meetingsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                if !calendarManager.liveMeetings.isEmpty {
                    sectionHeader("LIVE NOW")
                    ForEach(calendarManager.liveMeetings) { meeting in
                        MeetingRow(meeting: meeting, status: .live)
                    }
                }

                if !calendarManager.upcomingMeetings.isEmpty {
                    sectionHeader("UPCOMING")
                    ForEach(calendarManager.upcomingMeetings) { meeting in
                        MeetingRow(meeting: meeting, status: .upcoming)
                    }
                }

                if !calendarManager.pastMeetings.isEmpty {
                    sectionHeader("PAST")
                    ForEach(calendarManager.pastMeetings) { meeting in
                        MeetingRow(meeting: meeting, status: .past)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxHeight: 340)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 2)
    }
}

enum MeetingStatus {
    case live, upcoming, past
}

struct MeetingRow: View {
    let meeting: Meeting
    let status: MeetingStatus

    var body: some View {
        Button {
            NotionHelper.openMeetingsPage()
        } label: {
            HStack(spacing: 10) {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(meeting.title)
                        .font(.subheadline)
                        .fontWeight(status == .live ? .semibold : .regular)
                        .foregroundColor(status == .past ? .secondary : .primary)
                        .lineLimit(1)

                    Text(meeting.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if status == .live {
                    Text("START")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .cornerRadius(4)
                } else if status == .upcoming {
                    Text("\(meeting.minutesUntilStart)m")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        switch status {
        case .live: return .red
        case .upcoming: return .green
        case .past: return .gray
        }
    }
}
