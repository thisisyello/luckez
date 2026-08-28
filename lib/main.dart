import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:luckez/firebase_options.dart';
import 'package:luckez/theme/app_theme.dart';
import 'package:luckez/shell/main_shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LuckezApp());
}

class LuckezApp extends StatelessWidget {
  const LuckezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainShellPage(),
      theme: AppTheme.light,
    );
  }
}
