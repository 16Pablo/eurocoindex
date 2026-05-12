import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/app_constants.dart';

enum CoinImageType { coin, flag, value, yearIcon }

class CoinImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final url = _url;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget placeholder = Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );

    Widget errorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        type == CoinImageType.flag ? Icons.flag : type == CoinImageType.flag ? Icons.flag : Icons.euro,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: (width ?? 40) * 0.5,
      ),
    );

    if (url == null) return errorWidget;

    Widget img = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => errorWidget,
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    return img;
  }
}
