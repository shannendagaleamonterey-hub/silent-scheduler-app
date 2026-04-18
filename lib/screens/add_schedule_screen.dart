import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import 'package:silent_scheduler_app/services/dnd_service.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController titleController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedMode = 'silent';
  String language = 'en';

  @override
  void initState() {
    super.initState();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final lang = await StorageService.loadLanguage();
    setState(() {
      language = lang;
    });
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool isEndTimeValid() {
    if (startTime == null || endTime == null) return false;
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    return endMinutes > startMinutes;
  }

Future<void> saveSchedule() async {
  final t = AppStrings.text;

  if (titleController.text.trim().isEmpty ||
      selectedDate == null ||
      startTime == null ||
      endTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t(language, 'pleaseCompleteFields'))),
    );
    return;
  }

  if (!isEndTimeValid()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t(language, 'endTimeError'))),
    );
    return;
  }

  final List<Schedule> existingSchedules = await StorageService.loadSchedules();

  final newSchedule = Schedule(
    title: titleController.text.trim(),
    date: selectedDate!.toIso8601String(),
    startTime: formatTime(startTime),
    endTime: formatTime(endTime),
    mode: selectedMode,
    language: language,
  );

  existingSchedules.add(newSchedule);
  await StorageService.saveSchedules(existingSchedules);

  final scheduledStart = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    startTime!.hour,
    startTime!.minute,
  );

  final scheduledEnd = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    endTime!.hour,
    endTime!.minute,
  );

  final notificationsEnabled = await StorageService.loadNotificationsEnabled();

  if (notificationsEnabled) {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await NotificationService.scheduleNotification(
        id: notificationId,
        title: 'Meeting Reminder',
        body: 'Your meeting is coming soon. Please switch to $selectedMode mode.',
        scheduledTime: scheduledStart,
      );
    } catch (e) {
      debugPrint('Notification scheduling failed: $e');
    }
  }

  try {
    final dndGranted = await DndService.isAccessGranted();

    if (!mounted) return;

    if (!dndGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule saved, but please enable Do Not Disturb access.'),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    await DndService.scheduleModeChange(
      startTime: scheduledStart,
      endTime: scheduledEnd,
      mode: selectedMode,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Schedule saved. $selectedMode mode will activate at the meeting start time.',
        ),
      ),
    );
  } catch (e) {
    debugPrint('DND scheduling failed: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Schedule saved, but phone mode automation is not available yet.',
        ),
      ),
    );
  }

  Navigator.pop(context, true);
}

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(language, 'addSchedule')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: t(language, 'title'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Text(
                selectedDate == null
                    ? t(language, 'date')
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => startTime = picked);
                }
              },
              child: Text(
                '${t(language, 'startTime')}: ${formatTime(startTime)}',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => endTime = picked);
                }
              },
              child: Text(
                '${t(language, 'endTime')}: ${formatTime(endTime)}',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedMode,
              decoration: InputDecoration(
                labelText: t(language, 'mode'),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'silent',
                  child: Text(t(language, 'silent')),
                ),
                DropdownMenuItem(
                  value: 'vibrate',
                  child: Text(t(language, 'vibrate')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedMode = value);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSchedule,
              child: Text(t(language, 'save')),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await NotificationService.showInstantNotification(
                  title: 'Test Notification',
                  body: 'Notifications are working.',
                );
              },
              child: const Text('Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}