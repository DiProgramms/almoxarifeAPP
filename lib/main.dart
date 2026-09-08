import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';

  void main(){
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    runApp(AlmoxarifeApp());
  }

  class AlmoxarifeApp extends StatefulWidget {
    const AlmoxarifeApp({super.key});

    @override
    State<AlmoxarifeApp> createState() => _AlmoxarifeAppState();
  }

  class _AlmoxarifeAppState extends State<AlmoxarifeApp> {
    ThemeMode _themeMode = ThemeMode.light;
    
    @override
    void initState() {
      super.initState();
      _loadTheme();
    }

    Future<void> _loadTheme() async {
      final prefs = await SharedPreferences.getInstance();
      final dark = prefs.getBool('darkMode') ?? false;
      if(!mounted) return;
      setState(() {
        _themeMode = dark ? ThemeMode.dark : ThemeMode.light;});
    }

    Future<void> _toggleTheme() async {
      final prefs = await SharedPreferences.getInstance();
      final newDark = _themeMode != ThemeMode.dark;
      await prefs.setBool('darkMode', newDark);
      if(!mounted) return;
      setState(() {
        _themeMode = newDark ? ThemeMode.dark : ThemeMode.light;
      });
    }

    @override
    Widget build(BuildContext context){
      return MaterialApp(
        title: 'Almoxarife',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        home: HomeScreen(
          isDarkMode: _themeMode == ThemeMode.dark,
          onToggleTheme: _toggleTheme,
        ),
      );
    }
  }