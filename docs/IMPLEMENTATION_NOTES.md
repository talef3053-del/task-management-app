# Implementation notes

The supplied marking sheet totals 100 marks. The project source includes the corresponding task CRUD, SQLite schema and migration, task views, repeat rules, notifications, themes, progress tracking, CSV/PDF export, and documentation.

## Platform-specific storage and reminders
- Android/iOS native builds use the SQLite repository.
- Flutter Web uses browser-local preferences because the `sqflite` mobile plugin does not provide a browser SQLite engine in this project.
- Android reminders are scheduled through the OS notification scheduler.
- Browser reminders use the Notifications API and timers while the app tab is active. Closing the tab/browser or putting the device to sleep can prevent a browser timer from firing. Background push requires a service worker and push backend and is not included.

## Verify before submission
Run these commands on the target development computer:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For browser testing:

```bash
flutter run -d chrome
```

Test notification permission on a real Android phone and on localhost/HTTPS in a supported browser. The archive was prepared in an environment without the Flutter SDK, so a fresh Flutter build/analyze run is still required on the development machine.
