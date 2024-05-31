import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({
    super.key,
    required this.height,
    required this.width,
    this.padding,
    this.borderRadius,
    this.color,
  });

  final double height;
  final double width;
  final double? padding;
  final double? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1000),
      baseColor: Colors.transparent,
      highlightColor: Colors.white,
      child: Padding(
        // 0 here causes a white border to appear around the shimmer
        padding: EdgeInsets.all(padding ?? 0.2),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
            color: color ?? Colors.grey,
          ),
        ),
      ),
    );
  }
}
