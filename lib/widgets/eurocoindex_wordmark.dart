import 'package:material_ui/material_ui.dart';

/// Texto colorido con degradado de la marca EuroCoinDex.
class EuroCoinDexWordmark extends StatelessWidget {
  const EuroCoinDexWordmark({
    super.key,
    this.fontSize = 42,
    this.wordGap = 4,
  });

  static const Color _leftColor = Color(0xFFFFCC00);
  static const Color _rightColor = Color(0xFF3388FF);

  final double fontSize;
  final double wordGap;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'EuroCoinDexFont',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_leftColor, _rightColor],
        ).createShader(bounds.inflate(2));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Euro', style: textStyle),
            SizedBox(width: wordGap),
            Text('Coin', style: textStyle),
            SizedBox(width: wordGap),
            Text('Dex', style: textStyle),
          ],
        ),
      ),
    );
  }
}
