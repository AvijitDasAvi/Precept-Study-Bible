import 'package:calvinlockhart/core/utils/constants/image_path.dart';
import 'package:calvinlockhart/features/share/controller/share_controller.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareScreen extends StatelessWidget {
  final ShareController controller = Get.put(ShareController());

  ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new, size: 24),
                    ),
                  ),
                  Text(
                    LocalizationService.translate('share'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF00228E),
                image: DecorationImage(
                  image: AssetImage(ImagePath.mapImage),
                  fit: BoxFit.cover,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 120, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      "${controller.installCount.value}",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    LocalizationService.translate('installs_and_counting'),
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    LocalizationService.translate('share_paragraph'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    LocalizationService.translate('thank_you'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 96,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: controller.shareApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00228E),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        LocalizationService.translate('share'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
