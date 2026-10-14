import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Gestor de caché de imágenes de toda la app.
///
/// Una imagen ya descargada se sirve SIEMPRE desde el disco, sin consultar la
/// red. Solo se vuelven a comprobar al actualizar el catálogo ([invalidateAll]);
/// entonces únicamente se descargan las que han cambiado en GitHub.
///
/// OJO: `stalePeriod` no sirve para esto (solo decide cuándo se borran las
/// imágenes sin uso). Lo que decide cuándo se consulta el servidor es
/// `validTill`, que por defecto sale de Cache-Control de GitHub (5 minutos).
/// Por eso se usa un [FileService] propio que lo alarga a un año.
class AppCacheManager {
  static const key = 'eurocoindex_images';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 2000,
      fileService: _LongLivedHttpFileService(),
    ),
  );

  /// Marca todas las imágenes como "caducadas" SIN borrarlas. Al mostrarse
  /// cada una se verá la guardada y, en segundo plano, se preguntará a GitHub
  /// si ha cambiado: si no, no se descarga nada.
  static Future<void> invalidateAll() async {
    final repo = instance.config.repo;
    await repo.open(); // por si la base de datos aún no estuviera abierta
    final past = DateTime.now().subtract(const Duration(days: 1));
    final objects = await repo.getAllObjects();
    await Future.wait([
      for (final object in objects)
        instance.store.putFile(object.copyWith(validTill: past)),
    ]);
    // También se vacía la memoria de imágenes ya decodificadas de Flutter
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}

class _LongLivedHttpFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    return _LongLivedResponse(await super.get(url, headers: headers));
  }
}

class _LongLivedResponse implements FileServiceResponse {
  _LongLivedResponse(this._inner);

  final FileServiceResponse _inner;

  @override
  Stream<List<int>> get content => _inner.content;

  @override
  int? get contentLength => _inner.contentLength;

  @override
  int get statusCode => _inner.statusCode;

  @override
  DateTime get validTill => DateTime.now().add(const Duration(days: 365));

  @override
  String? get eTag => _inner.eTag;

  @override
  String get fileExtension => _inner.fileExtension;
}