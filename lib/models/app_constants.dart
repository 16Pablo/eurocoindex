class AppConstants {
  AppConstants._();

  // ── GitHub (base de datos remota) ────────────────────────────────────────
  static const String githubRawBase =
      'https://raw.githubusercontent.com/16Pablo/eurocoindex/main';

  static const String csvUrl = '$githubRawBase/data/coins.csv';

  static String coinImageUrl(String filename) =>
      '$githubRawBase/assets/coins/$filename';

  static String flagImageUrl(String filename) =>
      '$githubRawBase/assets/flags/$filename';

  static String valueImageUrl(String filename) =>
      '$githubRawBase/assets/values/$filename';

  // ── Caché local ──────────────────────────────────────────────────────────
  static const String cachedCsvFileName = 'coins_cache.csv';
  static const String collectionExportFileName = 'eurocoindex_coleccion.csv';

  // ── SQLite ───────────────────────────────────────────────────────────────
  static const String dbName = 'collection.db';
  static const String collectionTable = 'collection';

  // ── Filtros ──────────────────────────────────────────────────────────────
  static const List<int> allValues = [200, 100, 50, 20, 10, 5, 2, 1];

  static const Map<int, String> valueLabels = {
    200: '2 €',
    100: '1 €',
    50: '50 cts.',
    20: '20 cts.',
    10: '10 cts.',
    5: '5 cts.',
    2: '2 cts.',
    1: '1 ct.',
  };

  // Imagen representativa de cada valor (cara común)
  static const Map<int, String> valueImages = {
    200: '1999_200.webp',
    100: '1999_100.webp',
    50: '1999_50.webp',
    20: '1999_20.webp',
    10: '1999_10.webp',
    5: '1999_5.webp',
    2: '1999_2.webp',
    1: '1999_1.webp',
  };
}
