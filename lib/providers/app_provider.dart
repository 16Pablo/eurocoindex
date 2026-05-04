import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../services/coins_service.dart';
import '../services/collection_service.dart';

enum LoadingState { idle, loading, loaded, error }

enum CollectionFilter { all, collected, missing }

class AppProvider extends ChangeNotifier {
  final CoinsService _coinsService = CoinsService();
  final CollectionService _collectionService = CollectionService();

  // ── Estado ───────────────────────────────────────────────────────────────
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  List<Coin> _allCoins = [];
  Set<int> _collectedIds = {};

  // ── Getters ──────────────────────────────────────────────────────────────
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  List<Coin> get allCoins => _allCoins;
  Set<int> get collectedIds => _collectedIds;
  bool get isLoaded => _state == LoadingState.loaded;

  // ── Datos filtrados ──────────────────────────────────────────────────────

  List<Coin> get normalCoins =>
      _allCoins.where((c) => !c.conm && c.emitida).toList();

  List<Coin> get commCoins =>
      _allCoins.where((c) => c.conm && c.emitida).toList();

  List<Coin> get nationalCommCoins =>
      _allCoins.where((c) => c.conm && !c.conj && c.emitida).toList();

  List<Coin> get jointCommCoins =>
      _allCoins.where((c) => c.conm && c.conj && c.emitida).toList();

  /// Países únicos de monedas normales (ordenados)
  List<Map<String, String>> get normalCountries {
    final seen = <String>{};
    final result = <Map<String, String>>[];
    for (final c in normalCoins) {
      if (seen.add(c.idPais)) {
        result.add({'idPais': c.idPais, 'paisES': c.paisES, 'flag': c.flag});
      }
    }
    result.sort((a, b) => a['paisES']!.compareTo(b['paisES']!));
    return result;
  }

  /// Países únicos de conmemorativas nacionales (ordenados)
  List<Map<String, String>> get commCountries {
    final seen = <String>{};
    final result = <Map<String, String>>[];
    for (final c in nationalCommCoins) {
      if (seen.add(c.idPais)) {
        result.add({'idPais': c.idPais, 'paisES': c.paisES, 'flag': c.flag});
      }
    }
    result.sort((a, b) => a['paisES']!.compareTo(b['paisES']!));
    return result;
  }

  /// Años únicos de conmemorativas (ordenados)
  List<int> get commYears {
    final years = <int>{};
    for (final c in nationalCommCoins) {
      // Para conmemorativas, se usa anoinicio (año exacto de emisión)
      years.add(c.anoInicio);
    }
    return years.toList()..sort();
  }

  /// Series conjuntas únicas
  List<Map<String, String?>> get jointSeries {
    final seen = <String>{};
    final result = <Map<String, String?>>[];
    for (final c in jointCommCoins) {
      final key = c.conjOficial ?? c.idSerie ?? '';
      if (key.isNotEmpty && seen.add(key)) {
        result.add({
          'id': key,
          'titulo': c.titulo,
          'image': c.imageCoin,
        });
      }
    }
    return result;
  }

  // ── Filtros de monedas ────────────────────────────────────────────────────

  /// Monedas normales de un país, agrupadas por serie
  Map<String, List<Coin>> normalCoinsByCountry(String idPais) {
    final coins =
        normalCoins.where((c) => c.idPais == idPais).toList();
    final Map<String, List<Coin>> grouped = {};
    for (final c in coins) {
      final key = c.descrSerieES ?? 'Sin serie';
      grouped.putIfAbsent(key, () => []).add(c);
    }
    return grouped;
  }

  /// Monedas normales de un valor, todas las de todos los países
  List<Coin> normalCoinsByValue(int valor) {
    return normalCoins.where((c) => c.valor == valor).toList()
      ..sort((a, b) {
        final pc = a.paisES.compareTo(b.paisES);
        if (pc != 0) return pc;
        return a.anoInicio.compareTo(b.anoInicio);
      });
  }

  /// Conmemorativas nacionales de un país, agrupadas por serie
  Map<String, List<Coin>> commCoinsByCountry(String idPais) {
    final coins =
        nationalCommCoins.where((c) => c.idPais == idPais).toList()
          ..sort((a, b) => a.anoInicio.compareTo(b.anoInicio));
    final Map<String, List<Coin>> grouped = {};
    for (final c in coins) {
      final key = c.descrSerieES ?? 'Sin serie';
      grouped.putIfAbsent(key, () => []).add(c);
    }
    return grouped;
  }

  /// Conmemorativas nacionales de un año
  List<Coin> commCoinsByYear(int year) {
    return nationalCommCoins
        .where((c) => c.anoInicio == year)
        .toList()
      ..sort((a, b) => a.paisES.compareTo(b.paisES));
  }

  /// Conmemorativas conjuntas de una serie
  List<Coin> jointCoinsBySeries(String seriesId) {
    return jointCommCoins
        .where((c) =>
            (c.conjOficial ?? c.idSerie ?? '') == seriesId)
        .toList()
      ..sort((a, b) => a.paisES.compareTo(b.paisES));
  }

  /// Búsqueda avanzada
  List<Coin> search({
    int? valor,
    String? idPais,
    int? year,
    String? tag,
  }) {
    return _allCoins.where((c) {
      if (!c.emitida) return false;
      if (valor != null && c.valor != valor) return false;
      if (idPais != null && c.idPais != idPais) return false;
      if (year != null && !c.issuedInYear(year)) return false;
      if (tag != null && c.tagES != tag) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final pc = a.paisES.compareTo(b.paisES);
        if (pc != 0) return pc;
        return a.anoInicio.compareTo(b.anoInicio);
      });
  }

  /// Tags únicos disponibles (ordenados)
  List<String> get allTags {
    final tags = <String>{};
    for (final c in _allCoins) {
      if (c.tagES != null) tags.add(c.tagES!);
    }
    return tags.toList()..sort();
  }

  // ── Colección ────────────────────────────────────────────────────────────

  bool isCollected(int coinId) => _collectedIds.contains(coinId);

  Future<void> toggleCollection(int coinId) async {
    final wasAdded =
        await _collectionService.toggleCoin(coinId, _collectedIds);
    if (wasAdded) {
      _collectedIds = {..._collectedIds, coinId};
    } else {
      _collectedIds = _collectedIds.where((id) => id != coinId).toSet();
    }
    notifyListeners();
  }

  /// Filtra una lista de monedas según el filtro de colección
  List<Coin> applyFilter(List<Coin> coins, CollectionFilter filter) {
    switch (filter) {
      case CollectionFilter.all:
        return coins;
      case CollectionFilter.collected:
        return coins.where((c) => _collectedIds.contains(c.id)).toList();
      case CollectionFilter.missing:
        return coins.where((c) => !_collectedIds.contains(c.id)).toList();
    }
  }

  int countCollected(List<Coin> coins) =>
      coins.where((c) => _collectedIds.contains(c.id)).length;

  // ── Carga de datos ───────────────────────────────────────────────────────

  Future<void> loadData() async {
    if (_state == LoadingState.loading) return;
    _state = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _coinsService.loadCoins(),
        _collectionService.getCollectedIds(),
      ]);
      _allCoins = results[0] as List<Coin>;
      _collectedIds = results[1] as Set<int>;
      _state = LoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  // ── Exportar / Importar colección ────────────────────────────────────────

  Future<File> exportCollection() => _collectionService.exportCollection();

  Future<int> importCollection(File file) async {
    final count = await _collectionService.importCollection(file);
    _collectedIds = await _collectionService.getCollectedIds();
    notifyListeners();
    return count;
  }

  Future<DateTime?> getLastUpdate() => _coinsService.getLastUpdate();
}
