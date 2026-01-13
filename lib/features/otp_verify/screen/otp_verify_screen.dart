import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/common/widgets/custom_button.dart';
import '../controller/otp_verify_controller.dart';

class OtpVerifyScreen extends StatelessWidget {
  OtpVerifyScreen({super.key});

  final OtpVerifyController controller = Get.put(OtpVerifyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verify'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 55),
            Text(
              'We have sent you a 4 digit verification\ncode to your email. Please confirm and continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: TextField(
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      controller.updateDigit(index, val);
                      if (val.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                      if (val.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: getTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 20),

            Obx(
              () => Text(
                '00:${controller.startTime.value.toString().padLeft(2, '0')}',
                style: getTextStyle(
                  fontSize: 16,
                  color: controller.startTime.value < 10
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),

            SizedBox(height: 10),

            Obx(
              () => TextButton(
                onPressed: controller.canResend.value
                    ? controller.resendOTP
                    : null,
                child: Text('Resend OTP'),
              ),
            ),

            SizedBox(height: 20),

            Obx(
              () => CustomButton(
                onTap: controller.isOTPComplete && !controller.isLoading.value
                    ? () => controller.verifyOTP()
                    : null,
                titleWidget: controller.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
