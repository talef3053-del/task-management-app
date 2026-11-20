
import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../models/task.dart';

class BrowserNotifications {
  final Map<int, Timer> _timers = {};

  Future<void> requestPermission() async {
    try {
      if (web.Notification.permission != 'granted') {
        final permission =
        await web.Notification.requestPermission().toDart;

        debugPrint('Browser notification permission: $permission');
      }
    } catch (e) {
      debugPrint('Browser permission error: $e');
    }
  }

  Future<void> scheduleAll(List<Task> tasks) async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    if (web.Notification.permission != 'granted') {
      debugPrint('Notifications are not permitted.');
      return;
    }

    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted || task.id == null) continue;

      final due = _nextDue(task, now);

      if (due == null || !due.isAfter(now)) continue;

      final delay = due.difference(now);
      final taskId = task.id!;

      final timerDelay = delay > const Duration(days: 1)
          ? const Duration(days: 1)
          : delay;

      _timers[taskId] = Timer(timerDelay, () {
        if (delay > const Duration(days: 1)) {
          unawaited(scheduleAll(tasks));
          return;
        }

        try {
          web.Notification(
            'TaskBloom: ${task.title}',
            web.NotificationOptions(
              body: task.description.isEmpty
                  ? 'Your task is due now.'
                  : task.description,
              icon: 'icons/Icon-192.png',
              tag: 'task-$taskId',
            ),
          );

          debugPrint('Notification displayed for: ${task.title}');
        } catch (e) {
          debugPrint('Could not display notification: $e');
        }

        _timers.remove(taskId);

        if (task.isRepeating) {
          unawaited(scheduleAll(tasks));
        }
      });
    }
  }

  DateTime? _nextDue(Task task, DateTime now) {
    if (!task.isRepeating || task.recurrence == null) {
      return task.dueDateTime.isAfter(now)
          ? task.dueDateTime
          : null;
    }

    final rule = task.recurrence!;

    var day = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

    final today = DateTime(now.year, now.month, now.day);

    if (day.isBefore(today)) {
      day = today;
    }

    for (var i = 0; i < 370; i++) {
      final allowed = rule.type.name == 'daily' ||
          rule.weekdays.contains(day.weekday);

      final candidate = DateTime(
        day.year,
        day.month,
        day.day,
        task.dueTime.hour,
        task.dueTime.minute,
      );

      if (allowed && candidate.isAfter(now)) {
        return candidate;
      }

      day = day.add(const Duration(days: 1));
    }

    return null;
  }
}
