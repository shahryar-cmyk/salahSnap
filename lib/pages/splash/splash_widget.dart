import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'splash_model.dart';
export 'splash_model.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  static String routeName = 'Splash';
  static String routePath = '/splash';

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  late SplashModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Loading state track karne ke liye
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashModel());

    // POST-FRAME CALLBACK - UI ready hone ke baad run hoga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoNavigation();
    });
  }

  // Auto navigation ko separate function mein
  Future<void> _startAutoNavigation() async {
    if (!mounted || _isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    // Delay ke saath navigation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Safe navigation with error handling
    try {
      context.go('/onboarding');
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  // Manual button press handler
  Future<void> _handleGetStarted() async {
    if (_isNavigating) return; // Duplicate navigation prevent karo

    setState(() {
      _isNavigating = true;
    });

    HapticFeedback.lightImpact();

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    try {
      context.pushNamed(OnboardingSlideshowWidget.routeName);
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container - Optimized
                      Container(
                        width: 250.0,
                        height: 250.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/salat_snap_logo.png',
                            width: 231.02,
                            height: 200.0,
                            fit: BoxFit.cover,
                            // Image caching enable karo
                            cacheWidth: 250,
                            cacheHeight: 250,
                            // Error handling
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Title Text - Optimized
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 0.0),
                        child: RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          // Performance optimization
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Salat',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              TextSpan(
                                text: 'Snap',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                              )
                            ],
                            style: FlutterFlowTheme.of(context)
                                .displaySmall
                                .override(
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Button Section - Optimized
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FFButtonWidget(
                      onPressed: _isNavigating ? null : _handleGetStarted,
                      text: _isNavigating ? 'Loading...' : 'Get Started',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: GoogleFonts.inter().fontFamily,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
