import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';

/// COMPOSANT HARMONISÉ D'AFFICHAGE D'IMAGES AVEC CACHE ET OPTIMISATION MR SERGIO
/// Utilise `cached_network_image` pour mettre en cache les images de storage.mrsergio.dev.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    // 1. Image distante (ex: https://storage.mrsergio.dev/...)
    if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
      final widget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rose),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );

      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: widget);
      }
      return widget;
    }

    // 2. Web Blob / Network fallback
    if (kIsWeb) {
      final widget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: widget);
      }
      return widget;
    }

    // 3. Fichier local Mobile (Caméra / Galerie)
    final widget = Image.file(
      File(imageUrl),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: widget);
    }
    return widget;
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.roseClair,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(Icons.checkroom, color: AppColors.rose, size: 32),
      ),
    );
  }
}
