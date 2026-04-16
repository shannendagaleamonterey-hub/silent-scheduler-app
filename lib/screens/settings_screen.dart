import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String language = 'en';
  int timezoneOffset = 0;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final lang = await StorageService.loadLanguage();
    final offset = await StorageService.loadTimezone();
    final notifications = await StorageService.loadNotificationsEnabled();

    setState(() {
      language = lang;
      timezoneOffset = offset;
      notificationsEnabled = notifications;
    });
  }

  Future<void> saveSettings() async {
    await StorageService.saveLanguage(language);
    await StorageService.saveTimezone(timezoneOffset);
    await StorageService.saveNotificationsEnabled(notificationsEnabled);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(language, 'settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            Text(
              t(language, 'settings'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: language,
              decoration: InputDecoration(
                labelText: t(language, 'language'),
                prefixIcon: const Icon(Icons.language),
              ),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fil', child: Text('Filipino')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => language = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: timezoneOffset,
              decoration: InputDecoration(
                labelText: t(language, 'timezone'),
                prefixIcon: const Icon(Icons.access_time),
              ),
              items: List.generate(25, (index) {
                final value = index - 12;
                return DropdownMenuItem(
                  value: value,
                  child: Text('UTC ${value >= 0 ? '+' : ''}$value'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => timezoneOffset = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: Text(t(language, 'notifications')),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() => notificationsEnabled = value);
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save),
              label: Text(t(language, 'save')),
            ),
          ],
        ),
      ),
    );
  }
}
