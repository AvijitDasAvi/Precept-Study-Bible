import 'package:calvinlockhart/core/common/widgets/custom_app_bar.dart';
import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/features/auth/sign_up_email_verify/controller/sign_up_email_verify_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class SignUpEmailVerifyScreen extends StatelessWidget {
  SignUpEmailVerifyScreen({super.key});

  final SignUpEmailVerifyController controller = Get.put(
    SignUpEmailVerifyController(),
  );

  Widget _buildDigitField(int idx) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: controller.digitControllers[idx],
        focusNode: controller.digitFocusNodes[idx],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          controller.onDigitEntered(idx, v);
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFBFC9D9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFBFC9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF8AB5E3), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.back(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Text(
              LocalizationService.translate('otp_verify'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF21252C),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                LocalizationService.translate('otp_subtitle'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2B303A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigitField(0),
                SizedBox(width: 12),
                _buildDigitField(1),
                SizedBox(width: 12),
                _buildDigitField(2),
                SizedBox(width: 12),
                _buildDigitField(3),
              ],
            ),
            SizedBox(height: 16),
            Obx(() {
              final s = controller.timerSeconds.value;
              final mm = (s ~/ 60).toString().padLeft(2, '0');
              final ss = (s % 60).toString().padLeft(2, '0');
              return Text(
                '$mm:$ss',
                style: getTextStyle(color: Color(0xFFCF0404), fontSize: 12),
              );
            }),
            SizedBox(height: 12),
            Obx(() {
              final enabled = controller.timerSeconds.value == 0;
              return GestureDetector(
                onTap: enabled ? controller.resendCode : null,
                child: Text(
                  LocalizationService.translate('resend'),
                  style: getTextStyle(
                    color: enabled ? Color(0xFF005EC2) : Color(0xFF9FB7D9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            }),
            SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: 160,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isVerifying.value
                      ? null
                      : () async {
                          await controller.verifyCode();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00228E),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    shadowColor: Color(0xFF00228E).withValues(alpha: 0.4),
                  ),
                  child: controller.isVerifying.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          LocalizationService.translate('verify'),
                          style: getTextStyle(
                            color: Color(0xFFE6EFF9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
