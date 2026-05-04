import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';
import '../providers/app_provider.dart';
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

    // Años disponibles: 1999 al año actual
    final currentYear = DateTime.now().year;
    final years = List.generate(
        currentYear - 1999 + 1, (i) => 1999 + i);

    // Países únicos
    final countries = {
      for (final c in provider.allCoins) c.idPais: c.paisES
    }.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final tags = provider.allTags;

    final displayed = _results != null
        ? provider.applyFilter(_results!, _filter)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          // ── Panel de filtros ─────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Fila 1: Valor + País
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField<int>(
                        label: 'Valor',
                        value: _selectedValor,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todos')),
                          ...AppConstants.allValues.map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child:
                                  Text(AppConstants.valueLabels[v]!),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedValor = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DropdownField<String>(
                        label: 'País',
                        value: _selectedPais,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todos')),
                          ...countries.map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedPais = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Fila 2: Año + Tema
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField<int>(
                        label: 'Año',
                        value: _selectedYear,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todos')),
                          ...years.reversed.map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y'),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedYear = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DropdownField<String>(
                        label: 'Tema',
                        value: _selectedTag,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Todos')),
                          ...tags.map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedTag = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Botón buscar + limpiar
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

          // ── Resultados ───────────────────────────────────────────────
          if (_results != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${displayed!.length} resultado${displayed.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.countCollected(_results!)}/${_results!.length} obtenidas',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: displayed.isEmpty
                  ? const Center(
                      child: Text('Sin resultados para este filtro'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: displayed.length,
                      itemBuilder: (ctx, i) => CoinListItem(
                        coin: displayed[i],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) =>
                                CoinDetailScreen(coin: displayed[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ],

          if (_results == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Selecciona los filtros y pulsa Buscar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // Filtro Todas/Obtenidas/Faltantes
      bottomNavigationBar: _results != null
          ? _BottomFilterBar(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            )
          : null,
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

// ── Dropdown genérico ──────────────────────────────────────────────────────

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
      value: value,
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

// ── Barra de filtro inferior ──────────────────────────────────────────────

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
              color: Colors.black.withOpacity(0.08),
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
