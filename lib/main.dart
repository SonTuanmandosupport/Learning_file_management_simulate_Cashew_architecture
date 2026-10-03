import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'struct/app_state.dart';
import 'struct/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuanLyTaiLieuApp());
}

class QuanLyTaiLieuApp extends StatefulWidget {
  const QuanLyTaiLieuApp({super.key});

  @override
  State<QuanLyTaiLieuApp> createState() => _QuanLyTaiLieuAppState();
}

class _QuanLyTaiLieuAppState extends State<QuanLyTaiLieuApp> {
  late final DocumentManagerNotifier _appState;
  late final AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _appState = DocumentManagerNotifier();
    _settings = AppSettings();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Quản Lý Tài Liệu Học Tập',
          debugShowCheckedModeBanner: false,
          themeMode: _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _settings.primaryColor,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 1,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _settings.primaryColor,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 1,
              centerTitle: false,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: HomePage(
            appState: _appState,
            settings: _settings,
          ),
        );
      },
    );
  }
}
