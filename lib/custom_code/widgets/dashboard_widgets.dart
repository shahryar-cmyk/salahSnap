// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:android_intent_plus/android_intent.dart';

class DashboardWidgets extends StatefulWidget {
  const DashboardWidgets({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<DashboardWidgets> createState() => _DashboardWidgetsState();
}

class _DashboardWidgetsState extends State<DashboardWidgets> {
  List<Map<String, dynamic>> alarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      HapticFeedback.mediumImpact();
      await _loadAlarmsFromPrefs();
    });
  }

  Future<void> _loadAlarmsFromPrefs() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmString = prefs.getString('alarms');

      if (alarmString != null && alarmString.isNotEmpty) {
        final decoded = jsonDecode(alarmString) as List;
        setState(() {
          alarms = decoded
              .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item))
              .toList();
        });
      } else {
        setState(() => alarms = []);
      }
    } catch (e) {
      print('Error loading alarms: $e');
      setState(() => alarms = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: FlutterFlowTheme.of(context).primary,
        ),
      );
    }

    // Filter alarms to show only unique times
    final uniqueAlarms = alarms
        .fold<Map<String, Map<String, dynamic>>>(
          {},
          (map, alarm) {
            final time = alarm['time']?.toString() ?? '';
            if (!map.containsKey(time)) {
              map[time] = alarm;
            }
            return map;
          },
        )
        .values
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (alarms.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Take a picture to set an alarm',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      fontSize: 17.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
        if (alarms.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAlarmsFromPrefs,
              child: ListView.builder(
                itemCount: uniqueAlarms.length,
                itemBuilder: (context, index) {
                  final alarm = uniqueAlarms[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        alarm['prayer']?.toString() ?? 'Prayer',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                      subtitle: Text(
                        alarm['time']?.toString() ?? '',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      trailing: Icon(Icons.alarm, size: 30),
                      onTap: () async {
                        final intent = AndroidIntent(
                          action: 'android.intent.action.MAIN',
                          category: 'android.intent.category.LAUNCHER',
                          package: 'com.google.android.deskclock',
                        );
                        await intent.launch();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
