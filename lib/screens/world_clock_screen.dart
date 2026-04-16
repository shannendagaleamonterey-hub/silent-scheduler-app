import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  String language = 'en';
  int selectedOffset = 0;

  final Map<String, int> cities = {
    'Sydney': 11,
    'Tokyo': 9,
    'London': 0,
    'New York': -4,
    'Manila': 8,
  };

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final lang = await StorageService.loadLanguage();
    final offset = await StorageService.loadTimezone();
    setState(() {
      language = lang;
      selectedOffset = offset;
    });
  }

  DateTime cityTime(int hourOffset) {
    return DateTime.now().toUtc().add(Duration(hours: hourOffset));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.text;
    final myTime = DateTime.now().toUtc().add(Duration(hours: selectedOffset));

    return Scaffold(
      appBar: AppBar(
        title: Text(t(language, 'worldClocks')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
         Card(
           child: ListTile(
             leading: const CircleAvatar(
               child: Icon(Icons.person_pin_circle),
         ),
            title: Text(
              t(language, 'myTimezone'),
              style: const TextStyle(fontWeight: FontWeight.bold),
    ),
          subtitle: Text(
      'UTC ${selectedOffset >= 0 ? '+' : ''}$selectedOffset\n'
      '${DateFormat('hh:mm a, dd MMM yyyy').format(myTime)}',
    ),
  ),
),
          const SizedBox(height: 10),
          ...cities.entries.map((entry) {
            final time = cityTime(entry.value);
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.public),
                  ),
               title: Text(
                entry.key,
                 style: const TextStyle(fontWeight: FontWeight.bold),
       ),
                subtitle: Text(
             DateFormat('hh:mm a, dd MMM yyyy').format(time),
    ),
  ),
);
          }),
        ],
      ),
    );
  }
}