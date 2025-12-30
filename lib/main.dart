import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:salah_snap_version_second/l10n/app_localizations.dart';

import 'auth/custom_auth/auth_util.dart';
import 'auth/custom_auth/custom_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late final AppStateNotifier _appStateNotifier;
  GoRouter? _router;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await FlutterFlowTheme.initialize();
    await authManager.initialize();
    await FFAppState().initializePersistedState();

    _router = createRouter(_appStateNotifier);

    await Future.delayed(const Duration(milliseconds: 500));
    _appStateNotifier.stopShowingSplashImage();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // 🔒 Jab tak router ready nahi hota
    if (!_initialized || _router == null) {
      return MaterialApp(
        locale: appState.locale, // ✅ FIX
        supportedLocales: const [
          Locale('en'),
          Locale('ur'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'Salat Snap',
        scrollBehavior: MyAppScrollBehavior(),
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: false,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: false,
        ),
        themeMode: _themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // 🔥 Firebase initialize check
    if (Firebase.apps.isEmpty) {
      return MaterialApp(
        locale: appState.locale, // ✅ FIX
        supportedLocales: const [
          Locale('en'),
          Locale('ur'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // ✅ MOST IMPORTANT FIX
    return MaterialApp.router(
      locale: appState.locale, // 🔥 THIS WAS MISSING
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Salat Snap',
      scrollBehavior: MyAppScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router!,
    );
  }

  getRoute() {}

  getRouteStack() {}
}

class NavBarPage extends StatefulWidget {
  NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'Dashboard';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Dashboard': DashboardWidget(),
      'Profile': ProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).navigationButtonColor,
        unselectedItemColor: Color(0xFF747B83),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.alarm,
              size: 24.0,
            ),
            label: AppLocalizations.of(context)!.setAlarm,
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_sharp,
              size: 24.0,
            ),
            activeIcon: Icon(
              Icons.settings_sharp,
              size: 24.0,
            ),
            label: AppLocalizations.of(context)!.setting,
            tooltip: '',
          )
        ],
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('ur');

  Locale get locale => _locale;

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
