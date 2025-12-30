import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salah_snap_version_second/app_state.dart';
import 'package:salah_snap_version_second/flutter_flow/flutter_flow_theme.dart';
import 'package:salah_snap_version_second/l10n/app_localizations.dart';
import 'package:salah_snap_version_second/main.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = 'ur';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground, // ✅ FIX
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: FlutterFlowTheme.of(context).secondary,
        title: Text(
          AppLocalizations.of(context).language,
        ),
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

    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => selectedLanguage = languageCode);
        context.read<AppState>().changeLanguage(languageCode);
      },
      child: Card(
        // ✅ CARD FILL COLOR (FlutterFlow style)
        color: theme.secondaryBackground,
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          // side: BorderSide(
          //   color: isSelected ? theme.primary : theme.alternate,
          //   width: 2,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // ✅ ICON BACKGROUND (theme based)
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.primary.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 28,
                  color: FlutterFlowTheme.of(context)
                      .secondary, // ✅ visible in dark & light
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ TITLE TEXT (dark safe)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ✅ SUBTITLE TEXT (dark safe)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ✅ CHECK ICON (visible in dark mode)
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: FlutterFlowTheme.of(context).secondary,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
