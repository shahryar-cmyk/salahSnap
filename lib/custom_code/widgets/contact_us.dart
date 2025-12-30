import 'package:salah_snap_version_second/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 10),
                Text(l10n.contactEmail, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
