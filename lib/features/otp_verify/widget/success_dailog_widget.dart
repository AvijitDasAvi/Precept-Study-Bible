import 'package:calvinlockhart/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessDialog {
  static void show(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    IconPath.key,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 40),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00228E),
                  ),
                  child: Text("OK"),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
