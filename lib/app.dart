import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme/watchman_theme.dart';

class WatchmanApp extends StatelessWidget {
  const WatchmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidWhisperer Watchman',
      debugShowCheckedModeBanner: false,
      theme: WatchmanTheme.light(),
      darkTheme: WatchmanTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
