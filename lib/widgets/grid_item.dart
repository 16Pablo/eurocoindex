import 'package:flutter/material.dart';

import '../widgets/coin_image.dart';

class GridItem extends StatelessWidget {
  final String? label;
  final String? imageFilename;
  final CoinImageType imageType;
  final int? collected;
  final int? total;
  final VoidCallback onTap;

  const GridItem({
    super.key,
    this.label,
    this.imageFilename,
    this.imageType = CoinImageType.flag,
    this.collected,
    this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasProgress = collected != null && total != null && total! > 0;
    final progress = hasProgress ? collected! / total! : 0.0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen
              CoinImage(
                filename: imageFilename,
                type: imageType,
                width: 72,
                height: 48,
                fit: BoxFit.contain,
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Text(
                  label!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Progreso opcional
              if (hasProgress) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$collected/$total',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
