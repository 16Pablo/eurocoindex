import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive_layout.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCheckUpdate());
  }

  Future<void> _maybeCheckUpdate() async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    final provider = context.read<AppProvider>();
    final enabled = await provider.getCheckUpdatesOnStart();
    if (!enabled || !mounted) return;

    final hasUpdate = await provider.checkForRemoteUpdate();
    if (!hasUpdate || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Catálogo actualizado disponible'),
        content: const Text(
            'Hay monedas o imágenes nuevas en el catálogo. ¿Quieres descargarlas ahora?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Ahora no')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Actualizar')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppProvider>().loadData(clearImageCache: true);
    }
  }

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
    final layout = AdaptiveLayout.of(context);

    final normalCollected = provider.countCollected(provider.normalCoins);
    final normalTotal = provider.normalCoins.length;
    final commCollected = provider.countCollected(provider.commCoins);
    final commTotal = provider.commCoins.length;

    final normalButton = _TypeButton(
      label: 'Monedas Normales',
      iconAsset: 'assets/icons/icon_normal.webp',
      fallbackIcon: Icons.toll,
      collected: normalCollected,
      total: normalTotal,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FilterScreen(isComm: false),
        ),
      ),
    );

    final commButton = _TypeButton(
      label: 'Monedas Conmemorativas',
      iconAsset: 'assets/icons/icon_comm.webp',
      fallbackIcon: Icons.star_outlined,
      collected: commCollected,
      total: commTotal,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FilterScreen(isComm: true),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final paddingV = layout.isShortHeight ? 16.0 : 24.0;
        const paddingH = 24.0;

        final split = layout.computeTwoPaneSplit(
          constraints.maxWidth,
          minLeftWidth: 230,
          minRightWidth: 230,
          fallbackLeftRatio: 0.5,
          fallbackMaxLeft: 480,
          fallbackGap: 16,
          minCombinedWidth: 520,
        );

        final Widget buttonsSection;
        if (split != null && split.alignedToHinge) {
          final leftCardWidth = (split.leftWidth - paddingH).clamp(180.0, 480.0);
          buttonsSection = IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: leftCardWidth, child: normalButton),
                SizedBox(width: split.gapWidth),
                Expanded(child: commButton),
              ],
            ),
          );
        } else if (split != null) {
          buttonsSection = IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: normalButton),
                const SizedBox(width: 16),
                Expanded(child: commButton),
              ],
            ),
          );
        } else {
          buttonsSection = Column(
            children: [
              normalButton,
              const SizedBox(height: 16),
              commButton,
            ],
          );
        }

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!layout.isShortHeight) const SizedBox(height: 8),
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
            SizedBox(height: layout.isShortHeight ? 16 : 24),
            buttonsSection,
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: split != null && split.alignedToHinge
                    ? double.infinity
                    : 960,
              ),
              child: content,
            ),
          ),
        );
      },
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
    final layout = AdaptiveLayout.of(context);
    final progress = total > 0 ? collected / total : 0.0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactCard = constraints.maxWidth < 280;
            final iconSize = layout.shortestSide < 360 || isCompactCard
                ? 52.0
                : (layout.isShortHeight ? 64.0 : 84.0);
            final hPadding = isCompactCard ? 14.0 : 20.0;
            final vPadding = layout.isShortHeight ? 16.0 : 20.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPadding,
                vertical: vPadding,
              ),
              child: Row(
                children: [
                  Image.asset(
                    iconAsset,
                    width: iconSize,
                    height: iconSize,
                    errorBuilder: (_, _, _) => Icon(
                      fallbackIcon,
                      size: iconSize,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: isCompactCard ? 12 : 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: isCompactCard ? 15 : 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                              progress == 1.0
                                  ? Colors.green
                                  : colorScheme.primary,
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
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            );
          },
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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_download_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Descarga inicial requerida',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'EuroCoinDex necesita conexión a internet la primera vez para descargar la base de datos de monedas y preparar tu álbum digital.\n\nUna vez descargada, podrás usar toda la aplicación completamente sin conexión.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message.isNotEmpty &&
                message != 'Se necesita conexión a internet para descargar el catálogo por primera vez.') ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Descargar catálogo'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
