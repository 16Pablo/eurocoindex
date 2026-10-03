import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Gestor de caché de imágenes de toda la app.
///
/// Con un [stalePeriod] muy largo, una imagen ya descargada se sirve
/// siempre desde disco sin comprobar el servidor. La única forma de
/// refrescarla es vaciar esta caché explícitamente — algo que solo
/// ocurre cuando el usuario pulsa "Actualizar catálogo" en Ajustes.
class AppCacheManager {
  static const key = 'eurocoindex_images';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 2000,
    ),
  );
}
