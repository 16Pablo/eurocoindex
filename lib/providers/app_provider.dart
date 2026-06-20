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

  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  List<Coin> _allCoins = [];
  Set<int> _collectedIds = {};

  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  List<Coin> get allCoins => _allCoins;
  Set<int> get collectedIds => _collectedIds;
  bool get isLoaded => _state == LoadingState.loaded;

  // ── Listas filtradas ──────────────────────────────────────────────────────

  List<Coin> get normalCoins =>
      _allCoins.where((c) => !c.conm && c.emitida).toList();

  List<Coin> get commCoins =>
      _allCoins.where((c) => c.conm && c.emitida).toList();

  List<Coin> get nationalCommCoins =>
      _allCoins.where((c) => c.conm && !c.conj && c.emitida).toList();

  List<Coin> get jointCommCoins =>
      _allCoins.where((c) => c.conm && c.conj && c.emitida).toList();

  // ── Países ────────────────────────────────────────────────────────────────

  List<Map<String, String>> get normalCountries =>
      _uniqueCountries(normalCoins);

  List<Map<String, String>> get commCountries =>
      _uniqueCountries(nationalCommCoins);

  List<Map<String, String>> get jointCountries =>
      _uniqueCountries(jointCommCoins);

  List<Map<String, String>> _uniqueCountries(List<Coin> coins) {
    final seen = <String>{};
    final result = <Map<String, String>>[];
    for (final c in coins) {
      if (seen.add(c.idPais)) {
        result.add(
            {'idPais': c.idPais, 'paisES': c.paisES, 'flag': c.flag});
      }
    }
    result.sort((a, b) => a['paisES']!.compareTo(b['paisES']!));
    return result;
  }

  // ── Años de conmemorativas nacionales ─────────────────────────────────────

  List<int> get commYears {
    final years = <int>{};
    for (final c in nationalCommCoins) {
      years.add(c.anoInicio);
    }
    return years.toList()..sort();
  }

  // ── Series conjuntas (por IDserie + descr_serieES) ────────────────────────

  List<Map<String, String?>> get jointSeries {
    final seen = <String>{};
    final result = <Map<String, String?>>[];
    for (final c in jointCommCoins) {
      final key = c.idSerie ?? '';
      if (key.isNotEmpty && seen.add(key)) {
        result.add({
          'id': key,
          'titulo': c.descrSerieES,
          'image': c.imageCoin,
        });
      }
    }
    return result;
  }

  // ── Filtros de monedas ────────────────────────────────────────────────────

  Map<String, List<Coin>> normalCoinsByCountry(String idPais) =>
      _groupBySerie(normalCoins.where((c) => c.idPais == idPais).toList());

  List<Coin> normalCoinsByValue(int valor) {
    return normalCoins.where((c) => c.valor == valor).toList()
      ..sort((a, b) {
        final pc = a.paisES.compareTo(b.paisES);
        return pc != 0 ? pc : a.anoInicio.compareTo(b.anoInicio);
      });
  }

  Map<String, List<Coin>> commCoinsByCountry(String idPais) {
    final coins = nationalCommCoins
        .where((c) => c.idPais == idPais)
        .toList()
      ..sort((a, b) => a.anoInicio.compareTo(b.anoInicio));
    return _groupBySerie(coins);
  }

  List<Coin> commCoinsByYear(int year) {
    return nationalCommCoins
        .where((c) => c.anoInicio == year)
        .toList()
      ..sort((a, b) => a.paisES.compareTo(b.paisES));
  }

  List<Coin> jointCoinsByCountry(String idPais) {
    return jointCommCoins
        .where((c) => c.idPais == idPais)
        .toList()
      ..sort((a, b) => a.anoInicio.compareTo(b.anoInicio));
  }

  List<Coin> jointCoinsBySeries(String idSerie) {
    return jointCommCoins
        .where((c) => (c.idSerie ?? '') == idSerie)
        .toList()
      ..sort((a, b) => a.paisES.compareTo(b.paisES));
  }

  Map<String, List<Coin>> _groupBySerie(List<Coin> coins) {
    final Map<String, List<Coin>> grouped = {};
    for (final c in coins) {
      final key = c.descrSerieES ?? 'Sin serie';
      grouped.putIfAbsent(key, () => []).add(c);
    }
    return grouped;
  }

  // ── Búsqueda ──────────────────────────────────────────────────────────────

  List<Coin> search({int? valor, String? idPais, int? year, String? tag}) {
    return _allCoins.where((c) {
      if (!c.emitida) return false;
      if (valor != null && c.valor != valor) return false;
      if (idPais != null && c.idPais != idPais) return false;
      if (year != null && !c.issuedInYear(year)) return false;
      // El filtro de tag busca en tag, subtag y coincidencia
      if (tag != null &&
          c.tagES != tag &&
          c.subtagES != tag &&
          c.coincidencia != tag) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final valorCmp = b.valor.compareTo(a.valor);
        if (valorCmp != 0) return valorCmp;
        final anoCmp = a.anoInicio.compareTo(b.anoInicio);
        if (anoCmp != 0) return anoCmp;
        final dateCmp = a.sortKey.compareTo(b.sortKey);
        if (dateCmp != 0) return dateCmp;
        final titleA = a.titulo ?? a.descrSerieES ?? '';
        final titleB = b.titulo ?? b.descrSerieES ?? '';
        return titleA.compareTo(titleB);
      });
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final c in _allCoins) {
      if (c.tagES != null) tags.add(c.tagES!);
      if (c.subtagES != null) tags.add(c.subtagES!);
      if (c.coincidencia != null) tags.add(c.coincidencia!);
    }
    return tags.toList()..sort();
  }

  // ── Colección ─────────────────────────────────────────────────────────────

  bool isCollected(int coinId) => _collectedIds.contains(coinId);

  Future<void> toggleCollection(int coinId) async {
    final wasAdded =
        await _collectionService.toggleCoin(coinId, _collectedIds);
    if (wasAdded) {
      _collectedIds = {..._collectedIds, coinId};
    } else {
      _collectedIds =
          _collectedIds.where((id) => id != coinId).toSet();
    }
    notifyListeners();
  }

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

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> loadData({bool clearImageCache = false}) async {
    if (_state == LoadingState.loading) return;
    _state = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Si se pide actualización manual, borrar caché de imágenes
      // para que las imágenes nuevas se descarguen correctamente
      if (clearImageCache) {
        await _coinsService.clearImageCache();
      }
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

  // ── Exportar / Importar ───────────────────────────────────────────────────

  Future<File> exportCollection() => _collectionService.exportCollection();

  Future<int> importCollection(File file) async {
    final count = await _collectionService.importCollection(file);
    _collectedIds = await _collectionService.getCollectedIds();
    notifyListeners();
    return count;
  }

  Future<DateTime?> getLastUpdate() => _coinsService.getLastUpdate();
}
