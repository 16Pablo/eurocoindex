import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../models/app_constants.dart';
import '../models/coin.dart';
import '../providers/app_provider.dart';
import '../widgets/coin_image.dart';
import 'coin_detail_screen.dart';

class CoinDetailScreen extends StatelessWidget {
  final Coin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final collected = provider.isCollected(coin.id);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Galería de imágenes ──────────────────────────────────────
            if (images.isNotEmpty)
              _ImageGallery(images: images),

            const SizedBox(height: 20),

            // ── Título ───────────────────────────────────────────────────
            if (coin.titulo != null)
              Text(
                coin.titulo!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            if (coin.titulo != null) const SizedBox(height: 8),

            // ── Info rápida ──────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                    label: coin.valorLabel,
                    color: colorScheme.primary),
                _InfoChip(
                    icon: Icons.calendar_today,
                    label: coin.yearRange),
                if (coin.fecha != null && coin.fecha!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.event,
                    label: coin.fecha!),
                if (coin.conm)
                  _InfoChip(
                    icon: Icons.star,
                    label: 'Conmemorativa',
                    color: Colors.amber[700],
                  ),
                if (coin.conj)
                  _InfoChip(
                      icon: Icons.groups,
                      label: 'Emisión conjunta'),
                if (coin.frase != null)
                  _InfoChip(icon: Icons.bar_chart, label: coin.frase!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Descripción ──────────────────────────────────────────────
            if (coin.descrCoinES != null) ...[
              _SectionTitle('Descripción'),
              Text(coin.descrCoinES!,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 12),
            ],

            // ── Motivo (campo futuro) ────────────────────────────────────
            if (coin.motivoES != null) ...[
              _SectionTitle('Motivo'),
              Text(coin.motivoES!,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 12),
            ],

            // ── Detalles ─────────────────────────────────────────────────
            _SectionTitle('Detalles'),
            _DetailRow('País', '${coin.paisES} (${coin.paisVO})'),
            _DetailRow('Valor', coin.valorLabel),
            _DetailRow('Año de emisión', coin.yearRange),
            if (coin.descrSerieES != null)
              _DetailRow('Serie', coin.descrSerieES!),
            if (coin.tagES != null)
              _DetailRow('Categoría', coin.tagES!),
            if (coin.subtagES != null)
              _DetailRow('Subcategoría', coin.subtagES!),
            if (coin.coincidencia != null)
              _DetailRow('Coincidencia', coin.coincidencia!),
            if (coin.rareza != null)
              _DetailRow('Rareza', '${coin.frase ?? ''} (${coin.rareza})'),
            if (coin.conjOficial != null)
              _DetailRow('Serie conjunta', coin.conjOficial!),

            const SizedBox(height: 20),

            // ── Monedas relacionadas ──────────────────────────────────────
            if (related.isNotEmpty) ...[
              _SectionTitle(
                  'Monedas relacionadas · ${coin.tagES}'),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  itemBuilder: (context, i) {
                    final r = related[i];
                    return GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CoinDetailScreen(coin: r)),
                      ),
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
                              borderRadius: BorderRadius.circular(6),
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
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Lista horizontal de monedas relacionadas ──────────────────────────────

class _RelatedList extends StatelessWidget {
  final List<Coin> coins;
  const _RelatedList({required this.coins});

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
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => CoinDetailScreen(coin: r)),
            ),
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
                    borderRadius: BorderRadius.circular(6),
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
  const _ImageGallery({required this.images});

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
              height: 220,
              child: PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => CachedNetworkImage(
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
              imageProvider:
                  CachedNetworkImageProvider(widget.images[i]),
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
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
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
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3)),
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
