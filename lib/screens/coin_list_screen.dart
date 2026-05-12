import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../widgets/coin_list_item.dart';
import 'coin_detail_screen.dart';

class CoinListScreen extends StatefulWidget {
  final String title;
  final List<Coin>? coins;
  final Map<String, List<Coin>>? groupedCoins;

  const CoinListScreen({
    super.key,
    required this.title,
    this.coins,
    this.groupedCoins,
  }) : assert(coins != null || groupedCoins != null);

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  CollectionFilter _filter = CollectionFilter.all;
  String? _selectedSerie;

  List<String> get _serieKeys {
    if (widget.groupedCoins == null) return [];
    final keys = widget.groupedCoins!.keys.toList();
    // "Sin serie" siempre primero
    keys.sort((a, b) {
      if (a == 'Sin serie') return -1;
      if (b == 'Sin serie') return 1;
      return a.compareTo(b);
    });
    return keys;
  }

  List<Coin> get _displayCoins {
    final provider = context.read<AppProvider>();
    List<Coin> coins;
    if (widget.groupedCoins != null) {
      final key = _selectedSerie ?? _serieKeys.first;
      coins = widget.groupedCoins![key] ?? [];
    } else {
      coins = widget.coins!;
    }
    // Ordenar por fecha (aaaa/mm/dd) o anoinicio, secundario por título
    coins = List.of(coins)..sort(_compareCoin);
    return provider.applyFilter(coins, _filter);
  }

  int _compareCoin(Coin a, Coin b) {
    // Primero por DateSort (aaaa/mm/dd) o anoinicio como fallback
    final dateCmp = a.sortKey.compareTo(b.sortKey);
    if (dateCmp != 0) return dateCmp;
    // Secundario: título
    final titleA = a.titulo ?? a.descrSerieES ?? '';
    final titleB = b.titulo ?? b.descrSerieES ?? '';
    return titleA.compareTo(titleB);
  }

  @override
  void initState() {
    super.initState();
    if (_serieKeys.isNotEmpty) _selectedSerie = _serieKeys.first;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppProvider>();
    final coins = _displayCoins;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          if (widget.groupedCoins != null && _serieKeys.length > 1)
            _SeriesTabs(
              keys: _serieKeys,
              selected: _selectedSerie ?? _serieKeys.first,
              onSelect: (k) => setState(() => _selectedSerie = k),
            ),
          Expanded(
            child: coins.isEmpty
                ? const _EmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: coins.length,
                    itemBuilder: (context, i) => CoinListItem(
                      coin: coins[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoinDetailScreen(coin: coins[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomFilter(
        selected: _filter,
        onSelect: (f) => setState(() => _filter = f),
        allCount: _allCount,
        collectedCount: _collectedCount,
      ),
    );
  }

  int get _allCount {
    if (widget.groupedCoins != null) {
      final key = _selectedSerie ?? _serieKeys.first;
      return widget.groupedCoins![key]?.length ?? 0;
    }
    return widget.coins!.length;
  }

  int get _collectedCount {
    final provider = context.read<AppProvider>();
    List<Coin> coins;
    if (widget.groupedCoins != null) {
      final key = _selectedSerie ?? _serieKeys.first;
      coins = widget.groupedCoins![key] ?? [];
    } else {
      coins = widget.coins!;
    }
    return provider.countCollected(coins);
  }
}

class _SeriesTabs extends StatelessWidget {
  final List<String> keys;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SeriesTabs(
      {required this.keys, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      color: colorScheme.surfaceContainerHighest,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: keys.length,
        itemBuilder: (context, i) {
          final key = keys[i];
          final isSel = key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(key),
              selected: isSel,
              onSelected: (_) => onSelect(key),
            ),
          );
        },
      ),
    );
  }
}

class _BottomFilter extends StatelessWidget {
  final CollectionFilter selected;
  final ValueChanged<CollectionFilter> onSelect;
  final int allCount;
  final int collectedCount;

  const _BottomFilter({
    required this.selected,
    required this.onSelect,
    required this.allCount,
    required this.collectedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final missing = allCount - collectedCount;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          _FilterBtn(
            label: 'Todas ($allCount)',
            selected: selected == CollectionFilter.all,
            onTap: () => onSelect(CollectionFilter.all),
          ),
          _FilterBtn(
            label: 'Obtenidas ($collectedCount)',
            selected: selected == CollectionFilter.collected,
            onTap: () => onSelect(CollectionFilter.collected),
          ),
          _FilterBtn(
            label: 'Faltantes ($missing)',
            selected: selected == CollectionFilter.missing,
            onTap: () => onSelect(CollectionFilter.missing),
          ),
        ],
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterBtn(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: selected
                ? Border(
                    top: BorderSide(color: colorScheme.primary, width: 2))
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? colorScheme.primary : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No hay monedas en esta categoría',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}
