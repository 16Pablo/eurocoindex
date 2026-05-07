import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';

class CoinsService {
  static const String _lastUpdateKey = 'csv_last_update';

  /// Carga las monedas: primero intenta GitHub, si falla usa caché local
  Future<List<Coin>> loadCoins() async {
    try {
      final csv = await _fetchFromGitHub();
      await _saveCache(csv);
      await _saveLastUpdate();
      return _parseCsv(csv);
    } catch (e) {
      debugPrint('No se pudo descargar CSV: $e. Usando caché local.');
      final cached = await _loadCache();
      if (cached != null) return _parseCsv(cached);
      throw Exception(
          'No hay conexión a internet y no hay datos almacenados localmente.');
    }
  }

  /// Borra la caché de imágenes de cached_network_image
  /// Se llama al actualizar el catálogo para forzar la descarga de imágenes nuevas
  Future<void> clearImageCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final dir = Directory(cacheDir.path);
      if (await dir.exists()) {
        // Eliminar archivos de caché de imágenes (cached_network_image
        // guarda las imágenes en el directorio temporal con prefijo libCachedImageData)
        await for (final entity in dir.list()) {
          if (entity is File) {
            final name = entity.path.split('/').last;
            if (name.startsWith('libCachedImageData') ||
                name.endsWith('.webp') ||
                name.endsWith('.png') ||
                name.endsWith('.jpg')) {
              try {
                await entity.delete();
              } catch (_) {}
            }
          } else if (entity is Directory) {
            final dirName = entity.path.split('/').last;
            if (dirName.contains('libCachedImageData') ||
                dirName.contains('cache')) {
              try {
                await entity.delete(recursive: true);
              } catch (_) {}
            }
          }
        }
      }
      debugPrint('Caché de imágenes borrada');
    } catch (e) {
      debugPrint('Error borrando caché de imágenes: $e');
    }
  }

  /// Descarga el CSV desde GitHub
  Future<String> _fetchFromGitHub() async {
    final response =
        await http.get(Uri.parse(AppConstants.csvUrl)).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    }
    throw HttpException('HTTP ${response.statusCode}');
  }

  /// Parsea el texto CSV a lista de monedas
  List<Coin> _parseCsv(String csvText) {
    final sep = csvText.contains(';') ? ';' : ',';

    final rows = const CsvToListConverter(
      eol: '\n',
      fieldDelimiter: ',',
    ).convert(csvText);

    List<List<dynamic>> parsed;
    if (sep == ';') {
      parsed = csvText
          .split('\n')
          .map((line) => line.split(';').map((e) => e.trim()).toList())
          .toList();
    } else {
      parsed = rows;
    }

    if (parsed.isEmpty) return [];

    final headers =
        parsed.first.map((h) => h.toString().trim()).toList();

    return parsed
        .skip(1)
        .where((row) => row.length >= headers.length)
        .map((row) {
          final map = <String, dynamic>{};
          for (int i = 0; i < headers.length; i++) {
            map[headers[i]] = i < row.length ? row[i] : null;
          }
          return Coin.fromCsvRow(map);
        })
        .where((c) => c.id > 0)
        .toList();
  }

  /// Guarda el CSV en caché local
  Future<void> _saveCache(String csv) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.cachedCsvFileName}');
    await file.writeAsString(csv, encoding: utf8);
  }

  /// Lee el CSV de la caché local
  Future<String?> _loadCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${AppConstants.cachedCsvFileName}');
      if (await file.exists()) {
        return await file.readAsString(encoding: utf8);
      }
    } catch (_) {}
    return null;
  }

  /// Guarda la fecha de última actualización
  Future<void> _saveLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastUpdateKey, DateTime.now().toIso8601String());
  }

  /// Obtiene la fecha de la última actualización de datos
  Future<DateTime?> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_lastUpdateKey);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}
