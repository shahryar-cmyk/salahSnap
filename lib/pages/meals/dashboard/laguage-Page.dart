import 'package:flutter/material.dart';
import 'package:salah_snap_version_second/app_state.dart';
import 'package:salah_snap_version_second/flutter_flow/flutter_flow_theme.dart';
import 'package:salah_snap_version_second/flutter_flow/flutter_flow_util.dart';
import 'package:salah_snap_version_second/flutter_flow/internationalization.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _languageCard(
              context,
              languageCode: 'en',
              title: 'English',
              subtitle: 'English',
              icon: Icons.language,
            ),
            const SizedBox(height: 12),
            _languageCard(
              context,
              languageCode: 'ur',
              title: 'اردو',
              subtitle: 'Urdu',
              icon: Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageCard(
    BuildContext context, {
    required String languageCode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = selectedLanguage == languageCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = languageCode;
        });

        /// 🔔 yahan aap localization logic add kar sakte hain
        /// FFAppState().language = languageCode;
      },
      child: Card(
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                child: Icon(icon,
                    color: FlutterFlowTheme.of(context).primary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle,
                    color: FlutterFlowTheme.of(context).primary, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
