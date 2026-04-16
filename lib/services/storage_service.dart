import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

class StorageService {
  static const String schedulesKey = 'schedules';
  static const String languageKey = 'language';
  static const String timezoneKey = 'timezone';
  static const String notificationsKey = 'notifications_enabled';

  static Future<void> saveSchedules(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final data = schedules.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(schedulesKey, data);
  }

  static Future<List<Schedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(schedulesKey) ?? [];
    return data.map((e) => Schedule.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language);
  }

  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? 'en';
  }

  static Future<void> saveTimezone(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(timezoneKey, offset);
  }

  static Future<int> loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(timezoneKey) ?? 0;
  }

  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsKey, enabled);
  }

  static Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsKey) ?? true;
  }
}