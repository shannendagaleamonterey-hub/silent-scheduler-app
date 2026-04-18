import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Schedule> schedules = [];
  String language = 'en';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final loadedSchedules = await StorageService.loadSchedules();
    final lang = await StorageService.loadLanguage();

    setState(() {
      schedules = loadedSchedules.reversed.toList();
      language = lang;
    });
  }

  String formatScheduleDate(String rawDate) {
    try {
      final parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }

  Future<void> deleteSchedule(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        schedules.removeAt(index);
      });

      await StorageService.saveSchedules(schedules.reversed.toList());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(language, 'history')),
      ),
      body: schedules.isEmpty
          ? Center(
              child: Text(t(language, 'noSchedules')),
            )
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final formattedDate = formatScheduleDate(schedule.date);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        schedule.mode == 'silent'
                            ? Icons.volume_off
                            : Icons.vibration,
                      ),
                    ),
                    title: Text(
                      schedule.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: $formattedDate\n'
                      'Start: ${schedule.startTime} | End: ${schedule.endTime}\n'
                      'Mode: ${schedule.mode}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteSchedule(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}