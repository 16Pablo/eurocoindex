import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadData(),
      child: const EuroCoinDexApp(),
    ),
  );
}

class EuroCoinDexApp extends StatelessWidget {
  const EuroCoinDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EuroCoinDex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // automático según el sistema
      home: const SplashScreen(),
    );
  }
}
