import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../providers/app_provider.dart';
import '../utils/adaptive_layout.dart';
import '../widgets/coin_image.dart';
import '../widgets/expressive_popup_menu_button.dart';
import '../widgets/grid_item.dart';
import 'coin_list_screen.dart';

class FilterScreen extends StatefulWidget {
  final bool isComm;
  const FilterScreen({super.key, required this.isComm});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

enum _FilterMode {
  country,
  value,
  year,
  jointCountry,
  jointSeries,
  yearOldestFirst,
  yearNewestFirst,
}

class _FilterScreenState extends State<FilterScreen> {
  _FilterMode _mode = _FilterMode.year;
  bool _isNational = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isComm) _mode = _FilterMode.country;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarForeground =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isComm ? 'Conmemorativas' : 'Normales'),
        actions: [
          if (!widget.isComm || (_isNational))
            ExpressivePopupMenuButton<_FilterMode>(
              icon: Icon(Icons.more_vert, color: appBarForeground),
              tooltip: 'Agrupar y ordenar',
              initialValue: _mode,
              onSelected: _onMenuSelection,
              itemBuilder: (_) => [
                if (!widget.isComm)
                  ExpressivePopupMenuItem(
                    value: _FilterMode.country,
                    icon: Icons.flag_outlined,
                    label: 'Por país',
                    selected: _mode == _FilterMode.country,
                  ),
                if (!widget.isComm)
                  ExpressivePopupMenuItem(
                    value: _FilterMode.value,
                    icon: Icons.euro_outlined,
                    label: 'Por valor',
                    selected: _mode == _FilterMode.value,
                  ),
                if (widget.isComm && _isNational) ...[
                  ExpressivePopupMenuItem(
                    value: _FilterMode.country,
                    icon: Icons.flag_outlined,
                    label: 'Por país',
                    selected: _mode == _FilterMode.country,
                  ),
                  ExpressivePopupMenuItem(
                    value: _FilterMode.year,
                    icon: Icons.calendar_today_outlined,
                    label: 'Por año',
                    selected: _mode == _FilterMode.year,
                  ),
                  if (_mode == _FilterMode.year) ...[
                    const PopupMenuDivider(),
                    ExpressivePopupMenuItem(
                      value: _FilterMode.yearOldestFirst,
                      icon: Icons.arrow_upward_rounded,
                      label: 'Años: antiguos primero',
                      selected:
                          !context.read<AppProvider>().commYearsNewestFirst,
                    ),
                    ExpressivePopupMenuItem(
                      value: _FilterMode.yearNewestFirst,
                      icon: Icons.arrow_downward_rounded,
                      label: 'Años: recientes primero',
                      selected:
                          context.read<AppProvider>().commYearsNewestFirst,
                    ),
                  ],
                ],
              ],
            ),
          if (widget.isComm && !_isNational)
            ExpressivePopupMenuButton<_FilterMode>(
              icon: Icon(Icons.more_vert, color: appBarForeground),
              tooltip: 'Modo de visualización',
              initialValue: _mode,
              onSelected: (mode) => setState(() => _mode = mode),
              itemBuilder: (_) => [
                ExpressivePopupMenuItem(
                  value: _FilterMode.jointCountry,
                  icon: Icons.flag_outlined,
                  label: 'Por país',
                  selected: _mode == _FilterMode.jointCountry,
                ),
                ExpressivePopupMenuItem(
                  value: _FilterMode.jointSeries,
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Por serie',
                  selected: _mode == _FilterMode.jointSeries,
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

  Future<void> _onMenuSelection(_FilterMode mode) async {
    if (mode == _FilterMode.yearOldestFirst ||
        mode == _FilterMode.yearNewestFirst) {
      try {
        await context
            .read<AppProvider>()
            .setCommYearsNewestFirst(mode == _FilterMode.yearNewestFirst);
      } catch (error) {
        debugPrint('Could not save commemorative year order: $error');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el orden de años.')),
        );
      }
      return;
    }

    setState(() => _mode = mode);
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
              _mode = _FilterMode.year;
            }),
          ),
          _TabButton(
            label: 'Emisiones conjuntas',
            selected: !_isNational,
            onTap: () => setState(() {
              _isNational = false;
              _mode = _FilterMode.jointSeries;
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

    return _ResponsiveGrid(
      childAspectRatio: 1.3,
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
                  isCommemorative: isComm,
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
    return _ResponsiveGrid(
      childAspectRatio: 1.3,
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

    return _ResponsiveGrid(
      childAspectRatio: 1.4,
      itemCount: years.length,
      itemBuilder: (context, i) {
        final year = years[i];
        final coins = provider.commCoinsByYear(year);
        final collected = provider.countCollected(coins);

        return GridItem(
          label: null,
          imageFilename: AppConstants.yearIconFilename(year),
          imageType: CoinImageType.yearIcon,
          imageWidth: 100,
          imageHeight: 70,
          collected: collected,
          total: coins.length,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoinListScreen(
                title: '$year',
                coins: coins,
                isCommemorative: true,
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

    return _ResponsiveGrid(
      childAspectRatio: 1.3,
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
                isCommemorative: true,
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

    return _ResponsiveGrid(
      childAspectRatio: 1.3,
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
                isCommemorative: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Cuadrícula adaptable al ancho ──────────────────────────────────────────

class _ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final IndexedWidgetBuilder itemBuilder;

  const _ResponsiveGrid({
    required this.itemCount,
    required this.childAspectRatio,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = AdaptiveLayout.gridColumnCount(
          constraints.maxWidth,
        );
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: selected
                ? Border(
                    bottom: BorderSide(color: textColor, width: 3))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? textColor : textColor.withValues(alpha: 0.7),
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
