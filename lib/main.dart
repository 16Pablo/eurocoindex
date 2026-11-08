import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Captura de errores síncronos del framework de Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  // 2. Captura de errores asíncronos no controlados del hilo de la plataforma
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error');
    return true; // Evita que la app se cierre bruscamente
  };

  // 3. Sustituye la pantalla gris de error en producción por una vista amigable
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar este elemento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Por favor, regresa a la pantalla anterior o reintenta.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

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
          theme: AppTheme.light(lightDynamic?.harmonized()),
          darkTheme: AppTheme.dark(darkDynamic?.harmonized()),
          
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
