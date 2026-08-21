import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'EuroCoinDex',
          debugShowCheckedModeBanner: false,
          
          // 3. Aplicamos los colores dinámicos al tema
          theme: AppTheme.light.copyWith(
            colorScheme: lightDynamic?.harmonized() ?? AppTheme.light.colorScheme,
          ),
          darkTheme: AppTheme.dark.copyWith(
            colorScheme: darkDynamic?.harmonized() ?? AppTheme.dark.colorScheme,
          ),
          
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
