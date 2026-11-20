# TaskBloom — Task Management App

A Flutter task planner with persistent storage, categories, recurring tasks, subtasks, progress, exports, themes, and due-time reminders.

## Features
- Today, Upcoming, Completed, and Repeated task views
- Add, edit, delete, search, filter, categorize, and complete tasks
- Due date and time reminders
- Daily and selected-weekday recurrence with automatic reset
- Subtasks with completion progress
- Light, dark, and system themes; accent colour and notification sound on/off
- CSV and PDF export, plus share/email hand-off
- Android/iOS use SQLite; Flutter Web stores tasks in browser-local preferences
- Phone notifications through `flutter_local_notifications`; browser notifications through the browser Notifications API

## Run on Android
1. Install Flutter and Android Studio, then connect a phone with USB debugging enabled.
2. From this folder run `flutter pub get`.
3. Run `flutter devices`, then `flutter run -d <device-id>`.
4. Open Settings → Enable phone notifications and allow the permission. Android may also ask for exact-alarm access.

## Run in a browser
1. Run `flutter pub get`.
2. Run `flutter run -d chrome` (or `flutter build web`).
3. Open Settings → Enable browser notifications and allow the permission.
4. Keep the app tab open for scheduled browser reminders. Browsers generally require HTTPS or localhost for notifications.

## Notification limitation
Phone reminders are scheduled by the operating system and can appear when the app is closed, subject to OS permissions and battery policies. Browser reminders are local in-tab timers: they can appear while the browser app is running, but are not guaranteed after the tab/browser closes or the device sleeps. Background web push requires a service worker and a push backend (such as Firebase Cloud Messaging), which is not included.

## Data and exports
Browser tasks are saved in that browser profile and are not automatically synced with the phone. CSV/PDF exports use the platform share sheet. The email option prepares a PDF to share; it does not send email automatically.

## Structure
- `lib/models/` — task, recurrence, and subtask models
- `lib/database/` — SQLite repository on mobile and browser-local repository on web
- `lib/providers/` — app state
- `lib/services/` — reminders, recurrence, and export
- `lib/screens/` and `lib/widgets/` — UI
