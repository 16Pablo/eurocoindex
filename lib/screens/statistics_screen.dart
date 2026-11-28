import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive_layout.dart';
import '../widgets/coin_image.dart';
import 'coin_detail_screen.dart';

const _statisticsExpansionShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(AppTheme.cardRadius)),
);

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: switch (provider.state) {
        LoadingState.loading ||
        LoadingState.idle => const Center(child: CircularProgressIndicator()),
        LoadingState.error => _StatisticsError(
          message: provider.errorMessage,
          onRetry: provider.loadData,
        ),
        LoadingState.loaded => _StatisticsContent(provider: provider),
      },
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.provider});

  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    final emittedCoins = provider.allCoins
        .where((coin) => coin.emitida)
        .toList();
    final normalCoins = emittedCoins.where((coin) => !coin.conm).toList();
    final commemorativeCoins = emittedCoins.where((coin) => coin.conm).toList();
    final normalCountries = _countryProgress(normalCoins, provider);
    final commemorativeCountries = _countryProgress(
      commemorativeCoins,
      provider,
    );
    final normalSeries = _seriesProgress(normalCoins, provider);
    final commemorativeSeries = _seriesProgress(commemorativeCoins, provider);
    final commemorativeYears = _yearProgress(commemorativeCoins, provider);
    final normalValues = _valueProgress(normalCoins, provider);
    final rarestCatalog = _rarestCoins(emittedCoins);
    final rarestCollected = _rarestCoins(
      emittedCoins.where((coin) => provider.isCollected(coin.id)).toList(),
    );
    final collected = provider.countCollected(emittedCoins);

    final layout = AdaptiveLayout.of(context);
    final maxWidth = layout.useNavigationRail ? 1120.0 : 860.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _CollectionSummary(
              collected: collected,
              total: emittedCoins.length,
            ),
            const _SectionTitle('Progreso por tipo'),
            _ProgressCard(
              title: 'Monedas normales',
              collected: provider.countCollected(normalCoins),
              total: normalCoins.length,
              icon: Icons.toll,
            ),
            _ProgressCard(
              title: 'Monedas conmemorativas',
              collected: provider.countCollected(commemorativeCoins),
              total: commemorativeCoins.length,
              icon: Icons.stars_outlined,
            ),
            const _SectionTitle('Progreso por país'),
            _ProgressListCard(
              title: 'Normales',
              entries: normalCountries,
              showFlags: true,
            ),
            _ProgressListCard(
              title: 'Conmemorativas',
              entries: commemorativeCountries,
              showFlags: true,
            ),
            const _SectionTitle('Progreso por año'),
            _ProgressListCard(
              title: 'Conmemorativas',
              entries: commemorativeYears,
            ),
            const _SectionTitle('Progreso por valor'),
            _ProgressListCard(title: 'Normales', entries: normalValues),
            const _SectionTitle('Logros'),
            _AchievementCard(
              title: 'Países completados',
              icon: Icons.flag_outlined,
              entries: [
                _achievementEntry('Normales', normalCountries),
                _achievementEntry('Conmemorativas', commemorativeCountries),
              ],
            ),
            _AchievementCard(
              title: 'Series completadas',
              icon: Icons.collections_bookmark_outlined,
              entries: [
                _achievementEntry('Normales', normalSeries),
                _achievementEntry('Conmemorativas', commemorativeSeries),
              ],
            ),
            _AchievementCard(
              title: 'Años conmemorativos completados',
              icon: Icons.calendar_month_outlined,
              entries: [
                _achievementEntry('Conmemorativas', commemorativeYears),
              ],
            ),
            const _SectionTitle('Monedas más raras'),
            _RarestCoinsCard(title: 'De mi colección', coins: rarestCollected),
            _RarestCoinsCard(title: 'Del catálogo', coins: rarestCatalog),
          ],
        ),
      ),
    );
  }
}

class _ProgressEntry {
  const _ProgressEntry({
    required this.label,
    required this.collected,
    required this.total,
    this.image,
  });

  final String label;
  final int collected;
  final int total;
  final String? image;
}

List<_ProgressEntry> _countryProgress(List<Coin> coins, AppProvider provider) {
  final groups = <String, List<Coin>>{};
  for (final coin in coins) {
    groups.putIfAbsent(coin.idPais, () => []).add(coin);
  }
  final entries = groups.entries.map((entry) {
    final firstCoin = entry.value.first;
    return _ProgressEntry(
      label: firstCoin.paisES,
      image: firstCoin.flag,
      collected: provider.countCollected(entry.value),
      total: entry.value.length,
    );
  }).toList()..sort((a, b) => a.label.compareTo(b.label));
  return entries;
}

List<_ProgressEntry> _seriesProgress(List<Coin> coins, AppProvider provider) {
  final groups = <String, List<Coin>>{};
  for (final coin in coins) {
    final seriesId = coin.idSerie;
    if (seriesId == null || seriesId.isEmpty) continue;
    groups.putIfAbsent(seriesId, () => []).add(coin);
  }
  final entries = groups.entries.map((entry) {
    final firstCoin = entry.value.first;
    return _ProgressEntry(
      label: firstCoin.descrSerieES ?? entry.key,
      collected: provider.countCollected(entry.value),
      total: entry.value.length,
    );
  }).toList()..sort((a, b) => a.label.compareTo(b.label));
  return entries;
}

List<_ProgressEntry> _yearProgress(List<Coin> coins, AppProvider provider) {
  final groups = <int, List<Coin>>{};
  for (final coin in coins) {
    groups.putIfAbsent(coin.anoInicio, () => []).add(coin);
  }
  final years = groups.keys.toList()..sort();
  return [
    for (final year in years)
      _ProgressEntry(
        label: '$year',
        collected: provider.countCollected(groups[year]!),
        total: groups[year]!.length,
      ),
  ];
}

List<_ProgressEntry> _valueProgress(List<Coin> coins, AppProvider provider) {
  return [
    for (final value in AppConstants.allValues)
      if (coins.any((coin) => coin.valor == value))
        _ProgressEntry(
          label: AppConstants.valueLabels[value]!,
          collected: provider.countCollected(
            coins.where((coin) => coin.valor == value).toList(),
          ),
          total: coins.where((coin) => coin.valor == value).length,
        ),
  ];
}

_AchievementEntry _achievementEntry(
  String label,
  List<_ProgressEntry> entries,
) {
  return _AchievementEntry(
    label: label,
    completed: entries.where((entry) => entry.collected == entry.total).length,
    total: entries.length,
  );
}

List<Coin> _rarestCoins(List<Coin> coins) {
  final ratedCoins =
      coins
          .where((coin) => coin.hasNumericRarity && _rarityValue(coin) != null)
          .toList()
        ..sort((a, b) {
          final rarityComparison = _rarityValue(b)!.compareTo(_rarityValue(a)!);
          return rarityComparison != 0
              ? rarityComparison
              : a.id.compareTo(b.id);
        });
  return ratedCoins.take(5).toList();
}

double? _rarityValue(Coin coin) {
  final rarity = coin.rareza?.replaceAll('%', '').replaceAll(',', '.').trim();
  return rarity == null ? null : double.tryParse(rarity);
}

class _CollectionSummary extends StatelessWidget {
  const _CollectionSummary({required this.collected, required this.total});

  final int collected;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final missing = total - collected;
    final progress = total == 0 ? 0.0 : collected / total;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Mi colección',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryValue('Obtenidas', collected, colorScheme.primary),
                _SummaryValue('Faltantes', missing, Colors.grey),
                _SummaryValue('Total catálogo', total, colorScheme.secondary),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  total > 0 && collected == total
                      ? Colors.green
                      : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% completado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.collected,
    required this.total,
    required this.icon,
  });

  final String title;
  final int collected;
  final int total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : collected / total;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, minHeight: 7),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('$collected / $total'),
          ],
        ),
      ),
    );
  }
}

class _ProgressListCard extends StatelessWidget {
  const _ProgressListCard({
    required this.title,
    required this.entries,
    this.showFlags = false,
  });

  final String title;
  final List<_ProgressEntry> entries;
  final bool showFlags;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        shape: _statisticsExpansionShape,
        collapsedShape: _statisticsExpansionShape,
        clipBehavior: Clip.antiAlias,
        title: Text(title),
        subtitle: Text(
          '${entries.where((entry) => entry.collected == entry.total).length}'
          ' de ${entries.length} completados',
        ),
        children: entries.isEmpty
            ? [const ListTile(title: Text('No hay monedas en el catálogo'))]
            : [
                for (final entry in entries)
                  _ProgressRow(entry: entry, showFlag: showFlags),
              ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.entry, this.showFlag = false});

  final _ProgressEntry entry;
  final bool showFlag;

  @override
  Widget build(BuildContext context) {
    final progress = entry.total == 0 ? 0.0 : entry.collected / entry.total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          if (showFlag) ...[
            CoinImage(
              filename: entry.image,
              type: CoinImageType.flag,
              width: 28,
              height: 20,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 3,
            child: Text(
              entry.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 66,
            child: Text(
              '${entry.collected}/${entry.total}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementEntry {
  const _AchievementEntry({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<_AchievementEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.label),
                    Text(
                      '${entry.completed} / ${entry.total}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.total > 0 && entry.completed == entry.total
                            ? Colors.green
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RarestCoinsCard extends StatelessWidget {
  const _RarestCoinsCard({required this.title, required this.coins});

  final String title;
  final List<Coin> coins;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: _statisticsExpansionShape,
        collapsedShape: _statisticsExpansionShape,
        clipBehavior: Clip.antiAlias,
        title: Text(title),
        children: coins.isEmpty
            ? [
                const ListTile(
                  title: Text('No hay monedas con rareza disponible'),
                ),
              ]
            : [
                for (var index = 0; index < coins.length; index++)
                  _RareCoinRow(rank: index + 1, coin: coins[index]),
              ],
      ),
    );
  }
}

class _RareCoinRow extends StatelessWidget {
  const _RareCoinRow({required this.rank, required this.coin});

  final int rank;
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        child: Row(
          children: [
            Text('$rank.', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 6),
            CoinImage(filename: coin.imageCoin, width: 36, height: 36),
          ],
        ),
      ),
      title: Text(
        coin.conm
            ? (coin.titulo ?? coin.descrSerieES ?? '')
            : coin.descrSerieES ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${coin.paisES} · ${coin.yearRange}'),
      trailing: Text(
        coin.rareza ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin)),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  const _StatisticsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
