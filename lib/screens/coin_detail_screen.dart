import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../services/app_cache_manager.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive_layout.dart';
import '../widgets/coin_image.dart';

class CoinDetailScreen extends StatelessWidget {
  final Coin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final collected = provider.isCollected(coin.id);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarForeground =
        isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CoinImage(
              filename: coin.flag,
              type: CoinImageType.flag,
              width: 28,
              height: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                coin.paisES,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Botón de colección en la barra
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: collected
                  ? 'Quitar de mi colección'
                  : 'Añadir a mi colección',
              onPressed: () => provider.toggleCollection(coin.id),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  collected
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                  key: ValueKey(collected),
                  color: appBarForeground,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CoinDetailBody(coin: coin),
    );
  }
}

/// Contenido reutilizable de detalle de moneda, adaptable tanto a vista
/// estrecha vertical como a dos columnas en tablets/apaisado/plegables o al
/// panel derecho del modo maestro-detalle.
class CoinDetailBody extends StatelessWidget {
  final Coin coin;
  final bool showInlineHeader;
  final ValueChanged<Coin>? onRelatedCoinTap;

  const CoinDetailBody({
    super.key,
    required this.coin,
    this.showInlineHeader = false,
    this.onRelatedCoinTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final layout = AdaptiveLayout.of(context);

    // Imágenes disponibles de esta moneda
    final images = [
      if (coin.imageCoin != null)
        AppConstants.coinImageUrl(coin.imageCoin!),
      if (coin.imageComun1 != null)
        AppConstants.valueImageUrl(coin.imageComun1!),
      if (coin.imageComun2 != null)
        AppConstants.valueImageUrl(coin.imageComun2!),
    ];

    // Monedas con la misma coincidencia (nivel más específico)
    final similar = coin.coincidencia != null
        ? provider.allCoins
            .where((c) =>
                c.coincidencia == coin.coincidencia &&
                c.id != coin.id &&
                c.emitida)
            .take(10)
            .toList()
        : <Coin>[];

    // Monedas relacionadas: mismo subtag si existe, si no mismo tag
    // Excluir las que ya aparecen en "similar"
    final similarIds = similar.map((c) => c.id).toSet();
    final related = (coin.subtagES != null || coin.tagES != null)
        ? provider.allCoins
            .where((c) =>
                c.id != coin.id &&
                c.emitida &&
                !similarIds.contains(c.id) &&
                (coin.subtagES != null
                    ? c.subtagES == coin.subtagES
                    : c.tagES == coin.tagES))
            .take(10)
            .toList()
        : <Coin>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final split = layout.computeTwoPaneSplit(
          constraints.maxWidth,
          minLeftWidth: 260,
          minRightWidth: 320,
          fallbackLeftRatio: 0.42,
          fallbackMinLeft: 280,
          fallbackMaxLeft: 440,
          fallbackGap: 24,
          minCombinedWidth: 640,
        );

        final detailsWidgets = <Widget>[
          if (showInlineHeader) ...[
            _InlineCoinHeader(coin: coin),
            const SizedBox(height: 16),
          ],
          if (coin.titulo != null) ...[
            Text(
              coin.titulo!,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
          ],
          // ── Info rápida ────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: coin.valorLabel,
                color: colorScheme.primary,
              ),
              _InfoChip(
                icon: Icons.calendar_today,
                label: coin.yearRange,
              ),
              if (coin.fecha != null && coin.fecha!.isNotEmpty)
                _InfoChip(
                  icon: Icons.event,
                  label: coin.fecha!,
                ),
              if (coin.conm)
                _InfoChip(
                  icon: Icons.star,
                  label: 'Conmemorativa',
                  color: Colors.amber[700],
                ),
              if (coin.conj)
                const _InfoChip(
                  icon: Icons.groups,
                  label: 'Emisión conjunta',
                ),
              if (coin.frase != null)
                _InfoChip(icon: Icons.bar_chart, label: coin.frase!),
            ],
          ),
          const SizedBox(height: 16),

          // ── Descripción ────────────────────────────────────────────────
          if (coin.descrCoinES != null) ...[
            const _SectionTitle('Descripción'),
            Text(
              coin.descrCoinES!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
          ],

          // ── Motivo (campo futuro) ──────────────────────────────────────
          if (coin.motivoES != null) ...[
            const _SectionTitle('Motivo'),
            Text(
              coin.motivoES!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
          ],

          // ── Detalles ───────────────────────────────────────────────────
          const _SectionTitle('Detalles'),
          _DetailRow('País', '${coin.paisES} (${coin.paisVO})'),
          _DetailRow('Valor', coin.valorLabel),
          _DetailRow('Año de emisión', coin.yearRange),
          if (coin.descrSerieES != null)
            _DetailRow('Serie', coin.descrSerieES!),
          if (coin.tagES != null) _DetailRow('Categoría', coin.tagES!),
          if (coin.subtagES != null)
            _DetailRow('Subcategoría', coin.subtagES!),
          if (coin.coincidencia != null)
            _DetailRow('Coincidencia', coin.coincidencia!),
          if (coin.rareza != null)
            _DetailRow(
              'Rareza',
              '${coin.frase ?? ''} (${coin.rareza})'.trim(),
              onInfoTap: coin.hasNumericRarity
                  ? () => showDialog<void>(
                        context: context,
                        builder: (_) => _RarityInfoDialog(coin: coin),
                      )
                  : null,
            ),
          if (coin.conjOficial != null)
            _DetailRow('Serie conjunta', coin.conjOficial!),

          const SizedBox(height: 20),

          // ── Monedas con la misma coincidencia ──────────────────────────
          if (similar.isNotEmpty) ...[
            _SectionTitle('Monedas similares · ${coin.coincidencia}'),
            const SizedBox(height: 8),
            _RelatedList(
              coins: similar,
              onCoinTap: onRelatedCoinTap,
            ),
            const SizedBox(height: 16),
          ],

          // ── Monedas relacionadas (mismo subtag o tag) ──────────────────
          if (related.isNotEmpty) ...[
            _SectionTitle(
              'Monedas relacionadas · ${coin.subtagES ?? coin.tagES}',
            ),
            const SizedBox(height: 8),
            _RelatedList(
              coins: related,
              onCoinTap: onRelatedCoinTap,
            ),
            const SizedBox(height: 16),
          ],
        ];

        // ── Vista ancha de 2 columnas (tablet / apaisado / plegable) ─────
        if (split != null) {
          final boundedHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : layout.height;
          final wideGalleryHeight = (boundedHeight - 96).clamp(160.0, 320.0);
          final leftWidth = split.alignedToHinge
              ? (split.leftWidth - 20).clamp(200.0, 520.0)
              : split.leftWidth;

          final content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (images.isNotEmpty)
                          _ImageGallery(
                            key: ValueKey(coin.id),
                            images: images,
                            height: wideGalleryHeight,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: split.gapWidth),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: detailsWidgets,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (split.alignedToHinge) return content;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: content,
            ),
          );
        }

        // ── Vista vertical clásica o panel estrecho ──────────────────────
        final compactGalleryHeight = constraints.hasBoundedHeight &&
                constraints.maxHeight < 520
            ? (constraints.maxHeight * 0.42).clamp(150.0, 220.0)
            : 220.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty) ...[
                _ImageGallery(
                  key: ValueKey(coin.id),
                  images: images,
                  height: compactGalleryHeight,
                ),
                const SizedBox(height: 20),
              ],
              ...detailsWidgets,
            ],
          ),
        );
      },
    );
  }
}

class _InlineCoinHeader extends StatelessWidget {
  final Coin coin;
  const _InlineCoinHeader({required this.coin});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final collected = provider.isCollected(coin.id);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
      ),
      child: Row(
        children: [
          CoinImage(
            filename: coin.flag,
            type: CoinImageType.flag,
            width: 30,
            height: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              coin.paisES,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (collected)
            FilledButton.tonalIcon(
              onPressed: () => provider.toggleCollection(coin.id),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Obtenida'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => provider.toggleCollection(coin.id),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Añadir'),
            ),
        ],
      ),
    );
  }
}

// ── Lista horizontal de monedas relacionadas ──────────────────────────────

class _RelatedList extends StatelessWidget {
  final List<Coin> coins;
  final ValueChanged<Coin>? onCoinTap;

  const _RelatedList({required this.coins, this.onCoinTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: coins.length,
        itemBuilder: (context, i) {
          final r = coins[i];
          return GestureDetector(
            onTap: () {
              if (onCoinTap != null) {
                onCoinTap!(r);
                return;
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinDetailScreen(coin: r),
                ),
              );
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              child: Column(
                children: [
                  CoinImage(
                    filename: r.imageCoin,
                    type: CoinImageType.coin,
                    width: 70,
                    height: 70,
                    borderRadius: BorderRadius.circular(AppTheme.imageRadius),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.paisES,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Galería con zoom ───────────────────────────────────────────────────────

class _ImageGallery extends StatefulWidget {
  final List<String> images;
  final double height;

  const _ImageGallery({
    super.key,
    required this.images,
    this.height = 220,
  });

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _openFullscreen(context, _current),
            child: SizedBox(
              height: widget.height,
              child: PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => CachedNetworkImage(
                  cacheManager: AppCacheManager.instance,
                  imageUrl: widget.images[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _current == i
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca para ampliar · Desliza para ver más',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(BuildContext context, int initial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: PhotoViewGallery.builder(
            itemCount: widget.images.length,
            pageController: PageController(initialPage: initial),
            builder: (_, i) => PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(
                widget.images[i],
                cacheManager: AppCacheManager.instance,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onInfoTap;

  const _DetailRow(this.label, this.value, {this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueText = Text(
      value,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: onInfoTap == null
                ? valueText
                : InkWell(
                    onTap: onInfoTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: valueText),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: '¿Qué significa la rareza?',
                          child: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Cuadro explicativo del cálculo y escala de rareza para una moneda.
class _RarityInfoDialog extends StatelessWidget {
  final Coin coin;

  const _RarityInfoDialog({required this.coin});

  static const List<(String, String)> _ranges = [
    ('0 % – 19 %', 'Muy común'),
    ('20 % – 39 %', 'Común'),
    ('40 % – 59 %', 'Intermedia'),
    ('60 % – 79 %', 'Rara'),
    ('80 % – 100 %', 'Muy rara'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(
      fontSize: 13.5,
      height: 1.45,
      color: colorScheme.onSurfaceVariant,
    );
    final currentLabel = coin.frase?.trim().toLowerCase();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '¿Qué significa la rareza?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        coin.frase ?? 'Rareza',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        coin.rareza ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'La rareza indica cuántas monedas de ese tipo se acuñaron en comparación con el resto del catálogo. Se calcula a partir de la tirada total de la moneda, sumando sus versiones de circulación y de colección (FDC y proof).',
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'El porcentaje va de 0 % a 100 %:\n'
                '· 0 % corresponde a la moneda con la mayor tirada del catálogo.\n'
                '· 100 % corresponde a la moneda con la menor tirada.',
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'Cuanto más alto es el porcentaje, menos ejemplares existen y más difícil será encontrarla.',
                style: bodyStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'La escala no es lineal. Pasar de 1 millón a 100.000 ejemplares sube la rareza lo mismo que pasar de 100.000 a 10.000. Así, las diferencias entre monedas poco acuñadas se aprecian igual de bien que entre las muy acuñadas.',
                style: bodyStyle,
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Porcentaje',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Rareza',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final (range, label) in _ranges)
                        Container(
                          decoration: BoxDecoration(
                            color: currentLabel == label.toLowerCase()
                                ? colorScheme.primaryContainer
                                    .withValues(alpha: 0.65)
                                : null,
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  range,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight:
                                        currentLabel == label.toLowerCase()
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: currentLabel == label.toLowerCase()
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight:
                                        currentLabel == label.toLowerCase()
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: currentLabel == label.toLowerCase()
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? color;
  const _InfoChip({this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 12, color: c)),
        ],
      ),
    );
  }
}
