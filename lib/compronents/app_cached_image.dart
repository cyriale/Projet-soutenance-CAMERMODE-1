import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';

/// COMPOSANT UNIVERSEL D'AFFICHAGE D'IMAGES SÉCURISÉ (BASE64, WEB, MOBILE, FICHIERS LOCAUX & HTTP)
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

  /// Traitement et sécurisation de l'URL
  String _getProcessedUrl(String url) {
    var clean = url.trim();
    if (clean.contains("images.unsplash.com") && clean.contains("auto=format")) {
      clean = clean.split("?").first;
    }

    if (kIsWeb && (clean.startsWith("http://") || clean.startsWith("https://")) && !clean.contains("weserv.nl")) {
      return "https://images.weserv.nl/?url=${Uri.encodeComponent(clean)}";
    }

    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final rawCleanUrl = imageUrl.trim();

    if (rawCleanUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    Widget imageWidget;

    // 1. BASE64 DATA URI (Images générées par Nano Banana 2 IA)
    if (rawCleanUrl.startsWith("data:image/") || rawCleanUrl.startsWith("data:application/")) {
      try {
        final String base64Data = rawCleanUrl.contains(",") ? rawCleanUrl.split(",").last : rawCleanUrl;
        final Uint8List bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
        if (borderRadius != null) {
          return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
        }
        return imageWidget;
      } catch (e) {
        debugPrint("Erreur décodage Base64 AppCachedImage : $e");
        return _buildErrorPlaceholder();
      }
    }

    final processedUrl = _getProcessedUrl(rawCleanUrl);

    // 2. SUR WEB (kIsWeb) : Image.network
    if (kIsWeb) {
      imageWidget = Image.network(
        processedUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            rawCleanUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (c, e, s) => _buildErrorPlaceholder(),
          );
        },
      );
    }
    // 3. URLs HTTP / HTTPS (Mobile & Desktop)
    else if (rawCleanUrl.startsWith("http://") || rawCleanUrl.startsWith("https://")) {
      imageWidget = CachedNetworkImage(
        imageUrl: rawCleanUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => Image.network(
          processedUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        ),
      );
    }
    // 4. FICHIERS LOCAUX (Caméra / Galerie)
    else if (rawCleanUrl.startsWith("/") || rawCleanUrl.startsWith("file://")) {
      final String cleanPath = rawCleanUrl.replaceFirst("file://", "");
      final file = File(cleanPath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      } else {
        imageWidget = _buildErrorPlaceholder();
      }
    }
    // 5. FALLBACK SÉCURISÉ
    else {
      imageWidget = Image.network(
        processedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.roseClair,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.rose),
        ),
      ),
    );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, color: AppColors.rose, size: 28),
            SizedBox(height: 2),
            Text("CamerMode", style: TextStyle(fontSize: 9, color: AppColors.rose, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
