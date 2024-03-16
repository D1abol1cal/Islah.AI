// ignore_for_file: library_private_types_in_public_api

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NamazReminder extends StatefulWidget {
  const NamazReminder({super.key});

  @override
  _NamazReminderState createState() => _NamazReminderState();
}

class _NamazReminderState extends State<NamazReminder> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PrayerTimes? _prayerTimes;
  Madhab _selectedMadhab = Madhab.hanafi;

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
    _initializeNotifications();
  }

  Future<void> _initializePrayerTimes() async {
    final today = DateTime.now();
    final coordinates =
        Coordinates(24.8607, 67.0011); // Change to your coordinates
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents(today.year, today.month, today.day),
      params,
    );
    setState(() {
      _prayerTimes = prayerTimes;
    });
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = IOSInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(
      String prayerName, DateTime dateTime) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'namaz_reminder_channel',
      'Namaz Reminder',
      'Reminders for Namaz times',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Convert DateTime to TZDateTime
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Namaz Reminder',
      'Time for $prayerName prayer!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Widget _buildMadhabSelection() {
    return Column(
      children: [
        const Text('Select Madhab:'),
        RadioListTile<Madhab>(
          title: const Text('Hanafi'),
          value: Madhab.hanafi,
          groupValue: _selectedMadhab,
          onChanged: (Madhab? value) {
            setState(() {
              _selectedMadhab = value!;
            });
            _initializePrayerTimes();
          },
        ),
        RadioListTile<Madhab>(
          title: const Text('Shafi'),
          value: Madhab.shafi,
          groupValue: _selectedMadhab,
          onChanged: (Madhab? value) {
            setState(() {
              _selectedMadhab = value!;
            });
            _initializePrayerTimes();
          },
        ),
      ],
    );
  }

  Widget _buildPrayerTimeCard(String title, DateTime time) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${time.hour}:${time.minute}',
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () {
          _scheduleNotification(title, time);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Reminder'),
      ),
      body: Center(
        child: _prayerTimes != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildMadhabSelection(),
                    _buildPrayerTimeCard('Fajr', _prayerTimes!.fajr),
                    _buildPrayerTimeCard('Dhuhr', _prayerTimes!.dhuhr),
                    _buildPrayerTimeCard('Asr', _prayerTimes!.asr),
                    _buildPrayerTimeCard('Maghrib', _prayerTimes!.maghrib),
                    _buildPrayerTimeCard('Isha', _prayerTimes!.isha),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _scheduleNotification('All prayers', DateTime.now());
                      },
                      child: const Text('Set Reminders for All Prayers'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
