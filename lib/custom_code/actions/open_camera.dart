// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, String>> alarmList = [];

List<Map<String, String>> getAlarmList() {
  return alarmList;
}

Future<void> openCamera() async {
  final Map<String, String> prayerTimes = {
    "Fajr": "4:20",
    "Dhuhr": "13:00",
    "Asr": "17:15",
    "Maghrib": "19:01",
    "Isha": "21:00",
  };

  // Remove delay or make it very short (1 second)
  for (var entry in prayerTimes.entries) {
    await _setSystemAlarm(entry.key, entry.value);
    await Future.delayed(Duration(seconds: 1)); // reduced delay
  }
}

Future<void> _setSystemAlarm(String prayerName, String time) async {
  if (!Platform.isAndroid) return;

  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  final intent = AndroidIntent(
    action: 'android.intent.action.SET_ALARM',
    arguments: {
      'android.intent.extra.alarm.HOUR': hour,
      'android.intent.extra.alarm.MINUTES': minute,
      'android.intent.extra.alarm.MESSAGE': '$prayerName Prayer',
      'android.intent.extra.alarm.SKIP_UI': true,
    },
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );

  try {
    await intent.launch();
    alarmList.add({'prayer': prayerName, 'time': time});

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarms', jsonEncode(alarmList));

    print('Alarm set for $prayerName at $time');
  } catch (e) {
    print('Error setting alarm for $prayerName: $e');
  }
}

DateTime _parseTime(String time) {
  final parts = time.split(':');
  final now = DateTime.now();
  return DateTime(
      now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
}

void _callback() {
  print('Alarm fired!');
}
