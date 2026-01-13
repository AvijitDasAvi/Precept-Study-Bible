import 'package:calvinlockhart/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class AdvertisementBanner extends StatelessWidget {
  final double horizontalPadding;
  final VoidCallback? onTap;
  const AdvertisementBanner({
    super.key,
    this.horizontalPadding = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - (horizontalPadding * 2);
    return Center(
      child: Container(
        width: width,
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFB0CDEC), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFFE6EFF9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.ad_units, color: AppColors.primary, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your Advertisement',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Learn More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
