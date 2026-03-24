# MeetingBuddy

A lightweight macOS menubar app that reminds you to start Notion's AI Meeting Notes transcription when your meetings begin.

## What it does

- Lives in your menubar — no dock icon, no windows
- Shows today's meetings pulled from your macOS Calendar
- Auto-opens [Notion Meet](https://www.notion.so/meet) when a meeting starts so you can kick off transcription with one click
- Sends a macOS notification 1 minute before each meeting
- Menubar icon turns red when a meeting is live

## Download

**[Download MeetingBuddy v1.0.0](https://github.com/kawus/MeetingBuddy/releases/latest/download/MeetingBuddy.zip)** — unzip, move to Applications, and run. No Xcode needed.

> If macOS blocks the app, go to System Settings → Privacy & Security and click "Open Anyway".

## Prerequisites (building from source)

- macOS 14.0 (Sonoma) or later
- Xcode 15+ (to build from source)
- Google Calendar synced to macOS Calendar (System Settings → Internet Accounts → Google → toggle Calendars on)
- A Notion workspace with [AI Meeting Notes](https://www.notion.com/product/ai-meeting-notes) enabled

## Install

1. Clone the repo:
   ```bash
   git clone https://github.com/kawus/MeetingBuddy.git
   ```

2. Open the project in Xcode:
   ```bash
   cd MeetingBuddy
   open MeetingBuddy.xcodeproj
   ```

3. Select your signing team in Xcode (Signing & Capabilities tab)

4. Press **Cmd+R** to build and run

5. Grant **Calendar** and **Notification** permissions when prompted

## Usage

- The mic icon appears in your menubar
- Click it to see today's meetings grouped by Live / Upcoming / Past
- Click any meeting to open Notion Meet
- Toggle **Auto-open** to automatically open Notion when meetings start
- When a meeting is live, the icon switches to a red recording indicator

## Build from command line

```bash
xcodebuild -project MeetingBuddy.xcodeproj -scheme MeetingBuddy -configuration Release build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/MeetingBuddy-*/Build/Products/Release/MeetingBuddy.app`. Move it to `/Applications` to keep it around.

## Run at login

To launch MeetingBuddy automatically when you log in:

1. Open **System Settings → General → Login Items**
2. Click **+** and select `MeetingBuddy.app`
