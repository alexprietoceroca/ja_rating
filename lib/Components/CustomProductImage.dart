import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ja_rating/Components/Services/firebase_image_service.dart';
import 'package:ja_rating/coloresapp.dart';

class CustomProductImage extends StatelessWidget {
  final int malId;
  final String originalUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CustomProductImage({
    super.key,
    required this.malId,
    required this.originalUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: FirebaseImageService.getCustomImageUrl(malId),
      builder: (context, snapshot) {
        final imageUrl = snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty
            ? snapshot.data!
            : originalUrl;
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade300,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Coloresapp.colorPrimario,
            child: const Icon(Icons.image_not_supported_rounded, color: Colors.white),
          ),
        );
      },
    );
  }
}