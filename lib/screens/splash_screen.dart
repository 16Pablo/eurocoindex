import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final Color colorIzquierdo = const Color(0xFFFFCC00);
  final Color colorDerecho = const Color(0xFF3388FF);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duración de la animación
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic, // Hace que empiece rápido y frene suave
    );

    _controller.forward().then((_) {
      _controller.forward().then((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()), 
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText(String initialLetter, String hiddenText) {
    // Estilo base usando tu fuente del pubspec.yaml
    final TextStyle estiloTexto = const TextStyle(
      fontFamily: 'EuroCoinDexFont',
      fontSize: 42,
      fontWeight: FontWeight.bold,
      color: Colors.white, // El color base no importa, el ShaderMask lo sobreescribe
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(initialLetter, style: estiloTexto),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  child: Text(hiddenText, style: estiloTexto),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detecta automáticamente si el móvil está en Modo Oscuro o Claro
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      // Fondo dinámico según el tema del dispositivo
      backgroundColor: const Color(0xFF1B6E8F),
      body: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [colorIzquierdo, colorDerecho],
            ).createShader(bounds);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedText('E', 'uro'),
              const SizedBox(width: 4),
              _buildAnimatedText('C', 'oin'),
              const SizedBox(width: 4),
              _buildAnimatedText('D', 'ex'),
            ],
          ),
        ),
      ),
    );
  }
}