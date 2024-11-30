import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 4, // Display 4 shimmer cards
      itemBuilder: (context, index) {
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[900]!, // Dark charcoal
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer Header Row
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shimmer for Index and Category
                      _buildShimmerContainer(width: 40, height: 15),
                      _buildShimmerContainer(width: 100, height: 12),
                    ],
                  ),
                ),
                // Shimmer Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildShimmerContainer(
                      width: double.infinity, height: 20),
                ),
                // Shimmer Content Preview
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildShimmerContainer(
                      width: double.infinity, height: 14),
                ),
                // Shimmer Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildShimmerContainer(
                        width: double.infinity, height: 200),
                  ),
                ),
                // Shimmer Source and Read More
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerContainer(width: 100, height: 12),
                      _buildShimmerContainer(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to create shimmer containers
  Widget _buildShimmerContainer(
      {required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}
