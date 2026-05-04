import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_constants.dart';

class CollectionService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getDatabasesPath();
    final path = join(dir, AppConstants.dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.collectionTable} (
            coin_id INTEGER PRIMARY KEY,
            added_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Obtiene todos los IDs de monedas en la colección
  Future<Set<int>> getCollectedIds() async {
    final db = await database;
    final rows = await db.query(AppConstants.collectionTable,
        columns: ['coin_id']);
    return rows.map((r) => r['coin_id'] as int).toSet();
  }

  /// Añade una moneda a la colección
  Future<void> addCoin(int coinId) async {
    final db = await database;
    await db.insert(
      AppConstants.collectionTable,
      {
        'coin_id': coinId,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Elimina una moneda de la colección
  Future<void> removeCoin(int coinId) async {
    final db = await database;
    await db.delete(
      AppConstants.collectionTable,
      where: 'coin_id = ?',
      whereArgs: [coinId],
    );
  }

  /// Alterna si una moneda está en la colección
  Future<bool> toggleCoin(int coinId, Set<int> currentIds) async {
    if (currentIds.contains(coinId)) {
      await removeCoin(coinId);
      return false;
    } else {
      await addCoin(coinId);
      return true;
    }
  }

  /// Exporta la colección como CSV simple (coin_id, added_at)
  Future<File> exportCollection() async {
    final db = await database;
    final rows = await db.query(AppConstants.collectionTable,
        orderBy: 'coin_id ASC');

    final buffer = StringBuffer();
    buffer.writeln('coin_id,added_at');
    for (final row in rows) {
      buffer.writeln('${row['coin_id']},${row['added_at']}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/${AppConstants.collectionExportFileName}');
    await file.writeAsString(buffer.toString(), encoding: utf8);
    return file;
  }

  /// Importa una colección desde un CSV exportado previamente
  /// Devuelve el número de monedas importadas
  Future<int> importCollection(File file) async {
    final content = await file.readAsString(encoding: utf8);
    final lines = content.split('\n');
    if (lines.isEmpty) return 0;

    final db = await database;
    // Limpiar colección actual antes de importar
    await db.delete(AppConstants.collectionTable);

    int count = 0;
    for (final line in lines.skip(1)) {
      final parts = line.split(',');
      if (parts.isEmpty || parts[0].trim().isEmpty) continue;
      final id = int.tryParse(parts[0].trim());
      if (id == null) continue;
      final addedAt =
          parts.length > 1 ? parts[1].trim() : DateTime.now().toIso8601String();
      await db.insert(AppConstants.collectionTable,
          {'coin_id': id, 'added_at': addedAt},
          conflictAlgorithm: ConflictAlgorithm.replace);
      count++;
    }
    return count;
  }

  /// Número total de monedas en la colección
  Future<int> getCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as c FROM ${AppConstants.collectionTable}');
    return (result.first['c'] as int?) ?? 0;
  }
}
