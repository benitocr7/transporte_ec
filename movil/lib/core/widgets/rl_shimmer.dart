import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class RlShimmerBox extends StatelessWidget {
  const RlShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.inputFill,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class RlLoadCardShimmer extends StatelessWidget {
  const RlLoadCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RlShimmerBox(width: 36, height: 36, borderRadius: 10),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  RlShimmerBox(width: 140, height: 14),
                  SizedBox(height: 6),
                  RlShimmerBox(width: 90, height: 11),
                ],
              ),
              const Spacer(),
              const RlShimmerBox(width: 60, height: 24, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          const RlShimmerBox(width: double.infinity, height: 1),
          const SizedBox(height: 12),
          Row(
            children: const [
              RlShimmerBox(width: 80, height: 11),
              Spacer(),
              RlShimmerBox(width: 60, height: 11),
              Spacer(),
              RlShimmerBox(width: 70, height: 11),
            ],
          ),
          const SizedBox(height: 12),
          const RlShimmerBox(width: double.infinity, height: 40, borderRadius: 10),
        ],
      ),
    );
  }
}

class RlConversationShimmer extends StatelessWidget {
  const RlConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const RlShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                RlShimmerBox(width: 160, height: 14),
                SizedBox(height: 6),
                RlShimmerBox(width: 220, height: 11),
              ],
            ),
          ),
          const RlShimmerBox(width: 40, height: 11),
        ],
      ),
    );
  }
}
