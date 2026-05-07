import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/coin_image.dart';
import '../widgets/grid_item.dart';
import 'coin_list_screen.dart';

class FilterScreen extends StatefulWidget {
  final bool isComm;
  const FilterScreen({super.key, required this.isComm});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

enum _FilterMode { country, value, year, jointCountry, jointSeries }

class _FilterScreenState extends State<FilterScreen> {
  _FilterMode _mode = _FilterMode.country;
  bool _isNational = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isComm ? 'Conmemorativas' : 'Normales'),
        actions: [
          // Menú solo para secciones que lo necesitan
          if (!widget.isComm || (_isNational))
            PopupMenuButton<_FilterMode>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              tooltip: 'Modo de visualización',
              onSelected: (mode) => setState(() => _mode = mode),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _FilterMode.country,
                  child: Row(children: [
                    Icon(Icons.flag_outlined),
                    SizedBox(width: 8),
                    Text('Por país'),
                  ]),
                ),
                if (!widget.isComm)
                  const PopupMenuItem(
                    value: _FilterMode.value,
                    child: Row(children: [
                      Icon(Icons.monetization_on_outlined),
                      SizedBox(width: 8),
                      Text('Por valor'),
                    ]),
                  ),
                if (widget.isComm && _isNational)
                  const PopupMenuItem(
                    value: _FilterMode.year,
                    child: Row(children: [
                      Icon(Icons.calendar_today_outlined),
                      SizedBox(width: 8),
                      Text('Por año'),
                    ]),
                  ),
              ],
            ),
          // Menú para emisiones conjuntas
          if (widget.isComm && !_isNational)
            PopupMenuButton<_FilterMode>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              tooltip: 'Modo de visualización',
              onSelected: (mode) => setState(() => _mode = mode),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _FilterMode.jointCountry,
                  child: Row(children: [
                    Icon(Icons.flag_outlined),
                    SizedBox(width: 8),
                    Text('Por país'),
                  ]),
                ),
                const PopupMenuItem(
                  value: _FilterMode.jointSeries,
                  child: Row(children: [
                    Icon(Icons.collections_bookmark_outlined),
                    SizedBox(width: 8),
                    Text('Por serie'),
                  ]),
                ),
              ],
            ),
        ],
        bottom: widget.isComm
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _buildTabs(),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: [
          _TabButton(
            label: 'Emisiones nacionales',
            selected: _isNational,
            onTap: () => setState(() {
              _isNational = true;
              _mode = _FilterMode.country;
            }),
          ),
          _TabButton(
            label: 'Emisiones conjuntas',
            selected: !_isNational,
            onTap: () => setState(() {
              _isNational = false;
              _mode = _FilterMode.jointCountry;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<AppProvider>();

    if (!widget.isComm) {
      if (_mode == _FilterMode.value) return _ValueGrid(provider: provider);
      return _CountryGrid(provider: provider, isComm: false);
    }

    if (!_isNational) {
      if (_mode == _FilterMode.jointSeries) {
        return _JointSeriesGrid(provider: provider);
      }
      return _JointCountryGrid(provider: provider);
    }

    if (_mode == _FilterMode.year) return _YearGrid(provider: provider);
    return _CountryGrid(provider: provider, isComm: true);
  }
}

// ── Cuadrícula de países ───────────────────────────────────────────────────

class _CountryGrid extends StatelessWidget {
  final AppProvider provider;
  final bool isComm;
  const _CountryGrid({required this.provider, required this.isComm});

  @override
  Widget build(BuildContext context) {
    final countries =
        isComm ? provider.commCountries : provider.normalCountries;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: countries.length,
      itemBuilder: (context, i) {
        final c = countries[i];
        final coins = isComm
            ? provider.nationalCommCoins
                .where((coin) => coin.idPais == c['idPais'])
                .toList()
            : provider.normalCoins
                .where((coin) => coin.idPais == c['idPais'])
                .toList();
        final collected = provider.countCollected(coins);

        return GridItem(
          label: c['paisES']!,
          imageFilename: c['flag'],
          imageType: CoinImageType.flag,
          collected: collected,
          total: coins.length,
          onTap: () {
            final grouped = isComm
                ? provider.commCoinsByCountry(c['idPais']!)
                : provider.normalCoinsByCountry(c['idPais']!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoinListScreen(
                  title: c['paisES']!,
                  groupedCoins: grouped,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Cuadrícula de valores (solo normales) ──────────────────────────────────

class _ValueGrid extends StatelessWidget {
  final AppProvider provider;
  const _ValueGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: AppConstants.allValues.length,
      itemBuilder: (context, i) {
        final v = AppConstants.allValues[i];
        final coins = provider.normalCoinsByValue(v);
        final collected = provider.countCollected(coins);

        return GridItem(
          label: AppConstants.valueLabels[v]!,
          imageFilename: AppConstants.valueImages[v],
          imageType: CoinImageType.value,
          collected: collected,
          total: coins.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoinListScreen(
                title: AppConstants.valueLabels[v]!,
                coins: coins,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Cuadrícula de años ─────────────────────────────────────────────────────

class _YearGrid extends StatelessWidget {
  final AppProvider provider;
  const _YearGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final years = provider.commYears;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: years.length,
      itemBuilder: (context, i) {
        final year = years[i];
        final coins = provider.commCoinsByYear(year);
        final collected = provider.countCollected(coins);

        return GridItem(
          label: '$year',
          imageFilename: null,
          collected: collected,
          total: coins.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoinListScreen(
                title: '$year',
                coins: coins,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Emisiones conjuntas: por país ──────────────────────────────────────────

class _JointCountryGrid extends StatelessWidget {
  final AppProvider provider;
  const _JointCountryGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final countries = provider.jointCountries;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: countries.length,
      itemBuilder: (context, i) {
        final c = countries[i];
        final coins = provider.jointCoinsByCountry(c['idPais']!);
        final collected = provider.countCollected(coins);

        return GridItem(
          label: c['paisES']!,
          imageFilename: c['flag'],
          imageType: CoinImageType.flag,
          collected: collected,
          total: coins.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoinListScreen(
                title: c['paisES']!,
                coins: coins,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Emisiones conjuntas: por serie ─────────────────────────────────────────

class _JointSeriesGrid extends StatelessWidget {
  final AppProvider provider;
  const _JointSeriesGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    final series = provider.jointSeries;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: series.length,
      itemBuilder: (context, i) {
        final s = series[i];
        final coins = provider.jointCoinsBySeries(s['id']!);
        final collected = provider.countCollected(coins);

        return GridItem(
          label: s['titulo'] ?? s['id']!,
          imageFilename: s['image'],
          imageType: CoinImageType.coin,
          collected: collected,
          total: coins.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoinListScreen(
                title: s['titulo'] ?? s['id']!,
                coins: coins,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Botón de tab ───────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: selected
                ? const Border(
                    bottom: BorderSide(color: Colors.white, width: 3))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
