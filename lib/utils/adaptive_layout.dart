import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';

/// Tipo físico de dispositivo o factor de forma detectado a partir de las
/// métricas reales de ventana y características de pantalla (bisagras/pliegues).
enum DeviceType {
  /// Teléfono clásico (`shortestSide < 600` dp sin pliegue activo).
  phone,

  /// Dispositivo plegable con bisagra o pliegue detectado en `displayFeatures`.
  foldable,

  /// Tablet o ventana amplia tipo escritorio/WSA (`shortestSide >= 600` dp).
  tablet,
}

/// Modo de diseño activo según el dispositivo, su postura y orientación.
enum LayoutMode {
  /// Modo teléfono clásico vertical: `NavigationBar` inferior, rejillas de
  /// 2 columnas y flujo vertical de una sola columna.
  phonePortrait,

  /// Modo apaisado / tablet / plegable abierto: `NavigationRail` lateral,
  /// rejillas adaptables al ancho y vistas multipanel o lado a lado.
  expandedOrLandscape,
}

/// Métricas calculadas para dividir una pantalla en dos paneles respetando
/// una bisagra física en plegables cuando existe.
class TwoPaneSplit {
  final double leftWidth;
  final double gapWidth;
  final bool alignedToHinge;

  const TwoPaneSplit({
    required this.leftWidth,
    required this.gapWidth,
    required this.alignedToHinge,
  });
}

/// Detector centralizado del factor de forma del dispositivo (teléfono clásico,
/// apaisado, tablet o plegable) y utilidades de diseño adaptable.
class AdaptiveLayout {
  final Size size;
  final Orientation orientation;
  final List<DisplayFeature> displayFeatures;

  const AdaptiveLayout._({
    required this.size,
    required this.orientation,
    required this.displayFeatures,
  });

  /// Obtiene la configuración adaptable actual y se suscribe únicamente a los
  /// cambios de tamaño, orientación o características de pantalla (bisagra).
  factory AdaptiveLayout.of(BuildContext context) {
    return AdaptiveLayout._(
      size: MediaQuery.sizeOf(context),
      orientation: MediaQuery.orientationOf(context),
      displayFeatures: MediaQuery.displayFeaturesOf(context),
    );
  }

  /// Ancho y alto lógicos de la ventana actual.
  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;

  bool get isLandscape => orientation == Orientation.landscape;

  /// Altura reducida (habitual en teléfonos en modo apaisado o multi-ventana).
  bool get isShortHeight => height < 480;

  /// Bisagra o pliegue vertical que divide la pantalla en izquierda y derecha.
  DisplayFeature? get verticalHinge {
    for (final feature in displayFeatures) {
      if (!_isFoldFeature(feature)) continue;
      final bounds = feature.bounds;
      if (bounds.height > bounds.width &&
          bounds.left > 0 &&
          bounds.right < width) {
        return feature;
      }
    }
    return null;
  }

  /// Bisagra o pliegue horizontal en postura semiabierta (p. ej. modo flip).
  DisplayFeature? get horizontalHinge {
    for (final feature in displayFeatures) {
      if (!_isFoldFeature(feature)) continue;
      final bounds = feature.bounds;
      if (bounds.width > bounds.height &&
          bounds.top > 0 &&
          bounds.bottom < height &&
          feature.state == DisplayFeatureState.postureHalfOpened) {
        return feature;
      }
    }
    return null;
  }

  bool get isFoldable => displayFeatures.any(_isFoldFeature);

  /// Indica si el dispositivo instalado (o pantalla desplegada actual) tiene
  /// tamaño de tablet (`sw600dp` o superior según clasificación Android).
  bool get isTabletSize => shortestSide >= 600;

  DeviceType get deviceType {
    if (isFoldable) return DeviceType.foldable;
    if (isTabletSize) return DeviceType.tablet;
    return DeviceType.phone;
  }

  /// Determina cuándo usar `NavigationRail` lateral en lugar de `NavigationBar`.
  ///
  /// Mantiene el modo teléfono clásico vertical en móviles verticales y en la
  /// pantalla externa estrecha de un plegable cerrado; cambia a modo rail en
  /// tablets (vertical u horizontal), plegables desplegados, ventanas amplias
  /// de WSA y teléfonos girados en horizontal.
  bool get useNavigationRail =>
      width >= 600 ||
      (isLandscape && width >= 480) ||
      (verticalHinge != null && width >= 540);

  /// Rail expandido con icono + etiqueta en línea en tablets grandes o WSA.
  bool get useExtendedRail => width >= 1000;

  LayoutMode get layoutMode => useNavigationRail
      ? LayoutMode.expandedOrLandscape
      : LayoutMode.phonePortrait;

  bool get isClassicPhonePortrait => layoutMode == LayoutMode.phonePortrait;

  /// Calcula el número de columnas para las rejillas de países, valores, años
  /// y series manteniendo la proporción visual de las 2 columnas del teléfono
  /// vertical (~165–210 dp de ancho por tarjeta con la misma `childAspectRatio`).
  static int gridColumnCount(
    double availableWidth, {
    double horizontalPadding = 24,
    double spacing = 10,
    double minTileWidth = 165,
  }) {
    final usableWidth = math.max(0.0, availableWidth - horizontalPadding);
    return math.max(
      2,
      ((usableWidth + spacing) / (minTileWidth + spacing)).floor(),
    );
  }

  /// Calcula los anchos para dividir un área de ancho [localWidth] en dos
  /// paneles, alineándose a la bisagra vertical de un plegable si queda dentro
  /// del área con ancho mínimo suficiente a ambos lados.
  TwoPaneSplit? computeTwoPaneSplit(
    double localWidth, {
    double minLeftWidth = 260,
    double minRightWidth = 280,
    double fallbackLeftRatio = 0.42,
    double? fallbackMinLeft,
    double fallbackMaxLeft = 420,
    double fallbackGap = 1,
    double minCombinedWidth = 700,
  }) {
    final hinge = verticalHinge;
    if (hinge != null) {
      // Si el widget vive dentro del NavigationRail, su origen local está
      // desplazado respecto al ancho total de la ventana.
      final leftOffset = math.max(0.0, width - localWidth);
      final localLeft = hinge.bounds.left - leftOffset;
      final localRight = hinge.bounds.right - leftOffset;
      final rawHingeWidth = math.max(0.0, localRight - localLeft);
      final effectiveGap = math.max(rawHingeWidth, 16.0);
      final extraSide = (effectiveGap - rawHingeWidth) / 2.0;
      final splitLeft = localLeft - extraSide;
      final splitRightRemaining = localWidth - splitLeft - effectiveGap;

      if (splitLeft >= minLeftWidth && splitRightRemaining >= minRightWidth) {
        return TwoPaneSplit(
          leftWidth: splitLeft,
          gapWidth: effectiveGap,
          alignedToHinge: true,
        );
      }
    }

    if (localWidth < minCombinedWidth) return null;

    final maxAllowedLeft = math.min(
      fallbackMaxLeft,
      math.max(minLeftWidth, localWidth - minRightWidth - fallbackGap),
    );
    final effectiveMinLeft =
        (fallbackMinLeft ?? minLeftWidth).clamp(minLeftWidth, maxAllowedLeft);
    final leftWidth = (localWidth * fallbackLeftRatio)
        .clamp(effectiveMinLeft, maxAllowedLeft);

    return TwoPaneSplit(
      leftWidth: leftWidth,
      gapWidth: fallbackGap,
      alignedToHinge: false,
    );
  }

  static bool _isFoldFeature(DisplayFeature feature) =>
      feature.type == DisplayFeatureType.hinge ||
      feature.type == DisplayFeatureType.fold;
}
