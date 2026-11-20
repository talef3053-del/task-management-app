import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recurrence_rule.dart';
import '../models/subtask.dart';
import '../models/task.dart';

/// Browser implementation. Tasks are stored locally in the browser profile.
/// Native Android/iOS/desktop builds continue to use SQLite.
class TaskRepository {
  static const _storageKey = 'taskbloom_tasks_v1';
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _read() async {
    final raw = (await _prefs).getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _write(List<Map<String, dynamic>> rows) async {
    await (await _prefs).setString(_storageKey, jsonEncode(rows));
  }

  Future<int> insertTask(Task task) async {
    final rows = await _read();
    final id = rows.fold<int>(0, (m, r) => (r['id'] as int) > m ? r['id'] as int : m) + 1;
    rows.add(_encode(task.copyWith(id: id)));
    await _write(rows);
    return id;
  }

  Map<String, dynamic> _encode(Task t) => {
    ...t.toMap(),
    'subtasks': t.subtasks.map((s) => s.toMap()..['task_id'] = t.id ?? 0).toList(),
    'recurrence': t.recurrence?.toMap(),
  };

  Task _decode(Map<String, dynamic> row) {
    final subs = ((row['subtasks'] as List?) ?? []).map((e) => Subtask.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    final rawRule = row['recurrence'];
    final rule = rawRule == null ? null : RecurrenceRule.fromMap(Map<String, dynamic>.from(rawRule as Map));
    return Task.fromMap(row, subtasks: subs, recurrence: rule);
  }

  Future<List<Task>> getAllTasks() async {
    final rows = await _read();
    rows.sort((a, b) {
      final c = (a['is_completed'] as int).compareTo(b['is_completed'] as int);
      if (c != 0) return c;
      final d = (a['due_date'] as String).compareTo(b['due_date'] as String);
      return d != 0 ? d : (a['due_time'] as String).compareTo(b['due_time'] as String);
    });
    return rows.map(_decode).toList();
  }

  Future<void> updateTask(Task task) async {
    final rows = await _read();
    final i = rows.indexWhere((r) => r['id'] == task.id);
    if (i >= 0) rows[i] = _encode(task);
    await _write(rows);
  }

  Future<void> deleteTask(int id) async {
    final rows = await _read();
    rows.removeWhere((r) => r['id'] == id);
    await _write(rows);
  }

  Future<void> setCompleted(int id, bool completed) async {
    final rows = await _read();
    final i = rows.indexWhere((r) => r['id'] == id);
    if (i >= 0) {
      rows[i]['is_completed'] = completed ? 1 : 0;
      rows[i]['completed_at'] = completed ? DateTime.now().toIso8601String() : null;
      await _write(rows);
    }
  }

  Future<void> resetForNewOccurrence(int taskId, DateTime today) async {
    final rows = await _read();
    final i = rows.indexWhere((r) => r['id'] == taskId);
    if (i < 0) return;
    final row = rows[i];
    row['is_completed'] = 0;
    row['completed_at'] = null;
    row['due_date'] = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    for (final sub in (row['subtasks'] as List? ?? [])) { sub['is_completed'] = 0; }
    final rule = row['recurrence'];
    if (rule != null) rule['last_generated_date'] = row['due_date'];
    await _write(rows);
  }
}
