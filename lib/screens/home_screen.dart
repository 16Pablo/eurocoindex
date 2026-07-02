import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'filter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EuroCoinDex'),
        actions: [
          if (provider.isLoaded)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${provider.countCollected(provider.allCoins.where((c) => c.emitida).toList())}/${provider.allCoins.where((c) => c.emitida).length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: provider.state == LoadingState.loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando catálogo de monedas...'),
                ],
              ),
            )
          : provider.state == LoadingState.error
              ? _ErrorView(
                  message: provider.errorMessage,
                  onRetry: () => provider.loadData(),
                )
              : _HomeContent(colorScheme: colorScheme),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final ColorScheme colorScheme;
  const _HomeContent({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final normalCollected = provider.countCollected(provider.normalCoins);
    final normalTotal = provider.normalCoins.length;
    final commCollected = provider.countCollected(provider.commCoins);
    final commTotal = provider.commCoins.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Mi colección',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${normalCollected + commCollected} de ${normalTotal + commTotal} monedas obtenidas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          // Botones en columna, más compactos
          _TypeButton(
            label: 'Monedas Normales',
            iconAsset: 'assets/icons/icon_normal.png',
            fallbackIcon: Icons.toll,
            collected: normalCollected,
            total: normalTotal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FilterScreen(isComm: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TypeButton(
            label: 'Monedas Conmemorativas',
            iconAsset: 'assets/icons/icon_comm.png',
            fallbackIcon: Icons.star_outlined,
            collected: commCollected,
            total: commTotal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FilterScreen(isComm: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final IconData fallbackIcon;
  final int collected;
  final int total;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.collected,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total > 0 ? collected / total : 0.0;

    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icono
              Image.asset(
                iconAsset,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) =>
                    Icon(fallbackIcon, size: 48, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              // Texto y progreso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor:
                            isDark ? Colors.grey[700] : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress == 1.0 ? Colors.green : colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$collected / $total',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No se pudieron cargar los datos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
