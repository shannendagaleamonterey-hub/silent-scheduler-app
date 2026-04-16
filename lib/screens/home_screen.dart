import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';
import 'add_schedule_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'world_clock_screen.dart';
import 'package:silent_scheduler_app/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      schedules = loadedSchedules;
      language = lang;
    });
  }

  Future<void> openAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddScheduleScreen()),
    );

    if (result == true) {
      loadData();
    }
  }

  Future<void> openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (result == true) {
      loadData();
    }
  }

  Widget buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(language, 'appTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    gradient: const LinearGradient(
      colors: [
        Color(0xFFCDB4DB), // lavender
        Color(0xFFA2D2FF), // pastel blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Silent Scheduler',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Stay organized with calm and simple scheduling.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
    ],
  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: openAddSchedule,
              icon: const Icon(Icons.add),
              label: Text(t(language, 'addSchedule')),
            ),
            const SizedBox(height: 20),
            buildMenuButton(
              icon: Icons.public,
              label: t(language, 'worldClock'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorldClockScreen()),
                );
              },
            ),
            buildMenuButton(
              icon: Icons.settings,
              label: t(language, 'settings'),
              onTap: openSettings,
            ),
            buildMenuButton(
              icon: Icons.history,
              label: t(language, 'history'),
              
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              t(language, 'savedSchedules'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            schedules.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t(language, 'noSchedules')),
                    ),
                  )
                : Column(
                    children: schedules.map((schedule) {
                      return Card(
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Date: ${schedule.date}\n'
                            'Start: ${schedule.startTime} | End: ${schedule.endTime}\n'
                            'Mode: ${schedule.mode}',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}