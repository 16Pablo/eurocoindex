import 'package:material_ui/material_ui.dart';

class AppTheme {
  AppTheme._();

  // Radios de forma para Material 3 Expressive
  static const double cardRadius = 24.0;
  static const double fieldRadius = 16.0;
  static const double dialogRadius = 28.0;
  static const double imageRadius = 16.0;

  // Semilla de color por defecto: se usa solo si el dispositivo no soporta
  // color dinámico (Android <12) o mientras dynamic_color aún no ha resuelto.
  static const Color _seedColor = Color(0xFF1B6E8F);

  // ── Tema claro ────────────────────────────────────────────────────────────
  // Acepta un ColorScheme dinámico ya "harmonized"; si es null, cae en la
  // semilla propia de la app.
  static ThemeData light([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: scheme.surface,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
        selectedColor: scheme.primary,
        labelStyle: const TextStyle(fontSize: 13),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(fieldRadius)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Tema oscuro ───────────────────────────────────────────────────────────
  static ThemeData dark([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: scheme.surfaceContainerHighest,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primaryContainer.withValues(alpha: 0.4),
        selectedColor: scheme.primary,
        labelStyle: TextStyle(fontSize: 13, color: scheme.onSurface),
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(fieldRadius)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }
}
