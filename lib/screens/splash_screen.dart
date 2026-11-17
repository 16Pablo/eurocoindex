import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final Color colorIzquierdo = const Color(0xFFFFCC00);
  final Color colorDerecho = const Color(0xFF3388FF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      fontFamily: 'EuroCoinDexFont',
      fontSize: 42,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B6E8F),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(_animation),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [colorIzquierdo, colorDerecho],
                ).createShader(bounds.deflate(2));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Euro', style: textStyle),
                    SizedBox(width: 4),
                    Text('Coin', style: textStyle),
                    SizedBox(width: 4),
                    Text('Dex', style: textStyle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
