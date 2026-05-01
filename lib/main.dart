import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/home_screen.dart';

void main(){

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(AlmoxarifeApp());
}

class AlmoxarifeApp extends StatelessWidget {
  const AlmoxarifeApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Almoxarife',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}