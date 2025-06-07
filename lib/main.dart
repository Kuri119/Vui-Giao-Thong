// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_gate.dart';
// import 'package:testing/firebase_options.dart';
// import "../views/widget_tree.dart";

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://mchdqxavztimeegffmrz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jaGRxeGF2enRpbWVlZ2ZmbXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1NjQwMDgsImV4cCI6MjA2MTE0MDAwOH0.ms0qzKUzc82IArEenf0QA9huA6fEsNeKGC9DxU-FQnk",
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed (
          seedColor: Colors.white,
        ),
      ),
      home: AuthGate(),
    );
  }
}