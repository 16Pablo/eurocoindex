import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../utils/adaptive_layout.dart';
import '../widgets/coin_list_item.dart';
import 'coin_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedValor;
  String? _selectedPais;
  int? _selectedYear;
  String? _selectedTag;
  List<Coin>? _results;
  CollectionFilter _filter = CollectionFilter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final currentYear = DateTime.now().year;
    final years = List.generate(
        currentYear - 1999 + 1, (i) => 1999 + i);

    final countries = {
      for (final c in provider.allCoins) c.idPais: c.paisES
    }.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final tags = provider.allTags;

    final displayed = _results != null
        ? provider.applyFilter(_results!, _filter)
        : null;

    if (provider.state == LoadingState.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buscar')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Catálogo no disponible',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Descarga el catálogo desde la pestaña Inicio con conexión a internet para poder buscar monedas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = AdaptiveLayout.of(context);
          final split = layout.computeTwoPaneSplit(
            constraints.maxWidth,
            minLeftWidth: 240,
            minRightWidth: layout.isShortHeight ? 280 : 320,
            fallbackLeftRatio: 0.35,
            fallbackMinLeft: 260,
            fallbackMaxLeft: 340,
            fallbackGap: 1,
            minCombinedWidth: layout.isShortHeight ? 520 : 640,
          );

          final valorItems = [
            const DropdownMenuItem<int>(value: null, child: Text('Todos')),
            ...AppConstants.allValues.map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(AppConstants.valueLabels[v]!),
              ),
            ),
          ];
          final paisItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Todos')),
            ...countries.map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              ),
            ),
          ];
          final yearItems = [
            const DropdownMenuItem<int>(value: null, child: Text('Todos')),
            ...years.reversed.map(
              (y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              ),
            ),
          ];
          final tagItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Todos')),
            ...tags.map(
              (t) => DropdownMenuItem(
                value: t,
                child: Text(t),
              ),
            ),
          ];

          if (split != null) {
            return Row(
              children: [
                SizedBox(
                  width: split.leftWidth,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DropdownField<int>(
                            label: 'Valor',
                            value: _selectedValor,
                            items: valorItems,
                            onChanged: (v) =>
                                setState(() => _selectedValor = v),
                          ),
                          const SizedBox(height: 10),
                          _DropdownField<String>(
                            label: 'País',
                            value: _selectedPais,
                            items: paisItems,
                            onChanged: (v) =>
                                setState(() => _selectedPais = v),
                          ),
                          const SizedBox(height: 10),
                          _DropdownField<int>(
                            label: 'Año',
                            value: _selectedYear,
                            items: yearItems,
                            onChanged: (v) =>
                                setState(() => _selectedYear = v),
                          ),
                          const SizedBox(height: 10),
                          _DropdownField<String>(
                            label: 'Tema',
                            value: _selectedTag,
                            items: tagItems,
                            onChanged: (v) =>
                                setState(() => _selectedTag = v),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _doSearch,
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _clearSearch,
                            child: const Text('Limpiar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (split.alignedToHinge)
                  SizedBox(width: split.gapWidth)
                else
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                Expanded(
                  child: _buildResultsArea(
                    context,
                    provider,
                    displayed,
                    showInlineBottomFilter: true,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField<int>(
                            label: 'Valor',
                            value: _selectedValor,
                            items: valorItems,
                            onChanged: (v) =>
                                setState(() => _selectedValor = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DropdownField<String>(
                            label: 'País',
                            value: _selectedPais,
                            items: paisItems,
                            onChanged: (v) =>
                                setState(() => _selectedPais = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownField<int>(
                            label: 'Año',
                            value: _selectedYear,
                            items: yearItems,
                            onChanged: (v) =>
                                setState(() => _selectedYear = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DropdownField<String>(
                            label: 'Tema',
                            value: _selectedTag,
                            items: tagItems,
                            onChanged: (v) =>
                                setState(() => _selectedTag = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _doSearch,
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _clearSearch,
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildResultsArea(
                  context,
                  provider,
                  displayed,
                  showInlineBottomFilter: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsArea(
    BuildContext context,
    AppProvider provider,
    List<Coin>? displayed, {
    required bool showInlineBottomFilter,
  }) {
    if (_results == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Selecciona los filtros y pulsa Buscar',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${displayed!.length} resultado${displayed.length != 1 ? 's' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${provider.countCollected(_results!)}/${_results!.length} obtenidas',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: displayed.isEmpty
              ? const Center(
                  child: Text('Sin resultados para este filtro'),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final twoCols = constraints.maxWidth >= 680;
                    if (!twoCols) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: displayed.length,
                        itemBuilder: (ctx, i) => CoinListItem(
                          coin: displayed[i],
                          onTap: () => _openCoinDetail(ctx, displayed[i]),
                        ),
                      );
                    }

                    final rowCount = (displayed.length / 2).ceil();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      itemCount: rowCount,
                      itemBuilder: (ctx, rowIndex) {
                        final firstIndex = rowIndex * 2;
                        final secondIndex = firstIndex + 1;
                        final first = displayed[firstIndex];
                        final second = secondIndex < displayed.length
                            ? displayed[secondIndex]
                            : null;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: CoinListItem(
                                  coin: first,
                                  onTap: () => _openCoinDetail(ctx, first),
                                ),
                              ),
                              Expanded(
                                child: second != null
                                    ? CoinListItem(
                                        coin: second,
                                        onTap: () =>
                                            _openCoinDetail(ctx, second),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        if (showInlineBottomFilter)
          SafeArea(
            top: false,
            child: _BottomFilterBar(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
      ],
    );
  }

  void _openCoinDetail(BuildContext context, Coin coin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoinDetailScreen(coin: coin),
      ),
    );
  }

  void _doSearch() {
    final provider = context.read<AppProvider>();
    final results = provider.search(
      valor: _selectedValor,
      idPais: _selectedPais,
      year: _selectedYear,
      tag: _selectedTag,
    );
    setState(() {
      _results = results;
      _filter = CollectionFilter.all;
    });
  }

  void _clearSearch() {
    setState(() {
      _selectedValor = null;
      _selectedPais = null;
      _selectedYear = null;
      _selectedTag = null;
      _results = null;
      _filter = CollectionFilter.all;
    });
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _BottomFilterBar extends StatelessWidget {
  final CollectionFilter filter;
  final ValueChanged<CollectionFilter> onChanged;

  const _BottomFilterBar(
      {required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: CollectionFilter.values
            .map((f) => Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(f),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: filter == f
                            ? Border(
                                top: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2))
                            : null,
                      ),
                      child: Text(
                        f == CollectionFilter.all
                            ? 'Todas'
                            : f == CollectionFilter.collected
                                ? 'Obtenidas'
                                : 'Faltantes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: filter == f
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: filter == f
                              ? colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
