import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../widgets/coin_image.dart';

class CoinListItem extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onTap;

  const CoinListItem({super.key, required this.coin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final collected = provider.isCollected(coin.id);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Imagen moneda
              CoinImage(
                filename: coin.imageCoin,
                type: CoinImageType.coin,
                width: 76,
                height: 76,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Valor
                    Text(
                      coin.valorLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Título o serie
                    Text(
                      coin.conm
                          ? (coin.titulo ?? coin.descrSerieES ?? '')
                          : (coin.descrSerieES ?? ''),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Descripción de la moneda
                    if (coin.descrCoinES != null &&
                        coin.descrCoinES!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        coin.descrCoinES!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    // País en idioma original
                    if (coin.paisVO.isNotEmpty)
                      Text(
                        coin.paisVO,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    // Año(s)
                    Text(
                      coin.yearRange,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Botón colección
              GestureDetector(
                onTap: () => provider.toggleCollection(coin.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: collected
                        ? colorScheme.primary
                        : (isDark ? Colors.grey[700] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    collected ? Icons.check : Icons.add,
                    color: collected ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
