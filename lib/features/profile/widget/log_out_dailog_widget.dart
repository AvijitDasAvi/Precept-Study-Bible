import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogoutDialog {
  static void showLogoutDialog({
    required Widget icon,
    required String message,
    required VoidCallback onYes,
    required VoidCallback onNo,
    Color iconBgColor = const Color(0xFFEDEDED),
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: iconBgColor,
                child: icon,
              ),
              SizedBox(height: 20),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF21252C),
                ),
              ),
              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: onYes,
                      child: Text(
                        "Yes",
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00228E),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00228E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: onNo,
                      child: Text(
                        "No",
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
