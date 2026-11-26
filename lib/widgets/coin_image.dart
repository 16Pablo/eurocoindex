import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';

import '../models/app_constants.dart';
import '../services/app_cache_manager.dart';

enum CoinImageType { coin, flag, value, yearIcon }

class CoinImage extends StatefulWidget {
  final String? filename;
  final CoinImageType type;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CoinImage({
    super.key,
    required this.filename,
    this.type = CoinImageType.coin,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  String? get _url {
    if (filename == null || filename!.isEmpty) return null;
    switch (type) {
      case CoinImageType.coin:
        return AppConstants.coinImageUrl(filename!);
      case CoinImageType.flag:
        return AppConstants.flagImageUrl(filename!);
      case CoinImageType.value:
        return AppConstants.valueImageUrl(filename!);
      case CoinImageType.yearIcon:
        return AppConstants.iconImageUrl(filename!);
    }
  }

  @override
  State<CoinImage> createState() => _CoinImageState();
}

class _CoinImageState extends State<CoinImage> {
  Future<FileInfo?>? _cachedFile;

  @override
  void initState() {
    super.initState();
    _checkCache(widget._url);
  }

  @override
  void didUpdateWidget(CoinImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._url != oldWidget._url) {
      _checkCache(widget._url);
    }
  }

  void _checkCache(String? url) {
    _cachedFile = url == null
        ? null
        : AppCacheManager.instance.getFileFromCache(url);
  }

  @override
  Widget build(BuildContext context) {
    final url = widget._url;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = widget.width;
    final height = widget.height;

    final shimmerPlaceholder = Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(width: width, height: height, color: Colors.white),
    );

    final staticPlaceholder = Container(
      width: width,
      height: height,
      color: isDark ? Colors.grey[800] : Colors.grey[300],
    );

    final errorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: Icon(
        widget.type == CoinImageType.flag ? Icons.flag : Icons.euro,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: (width ?? 40) * 0.5,
      ),
    );

    if (url == null) return errorWidget;

    Widget image = FutureBuilder<FileInfo?>(
      future: _cachedFile,
      builder: (context, snapshot) {
        final cachedFile = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return staticPlaceholder;
        }

        if (cachedFile != null &&
            cachedFile.validTill.isAfter(DateTime.now())) {
          return Image.file(
            cachedFile.file,
            width: width,
            height: height,
            fit: widget.fit,
            errorBuilder: (_, _, _) => errorWidget,
          );
        }

        final hasConfirmedMiss =
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            cachedFile == null;

        return CachedNetworkImage(
          imageUrl: url,
          cacheManager: AppCacheManager.instance,
          width: width,
          height: height,
          fit: widget.fit,
          placeholder: (_, _) =>
              hasConfirmedMiss ? shimmerPlaceholder : staticPlaceholder,
          errorWidget: (_, _, _) => errorWidget,
        );
      },
    );

    if (widget.borderRadius != null) {
      image = ClipRRect(borderRadius: widget.borderRadius!, child: image);
    }

    return image;
  }
}
