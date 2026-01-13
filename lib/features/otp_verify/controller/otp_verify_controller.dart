import 'dart:async';
import 'package:calvinlockhart/features/otp_verify/widget/success_dailog_widget.dart';
import 'package:get/get.dart';

class OtpVerifyController extends GetxController {
  var otpDigits = <String>['', '', '', ''].obs;
  var startTime = 55.obs;
  var canResend = false.obs;
  var isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    startTime.value = 55;
    canResend.value = false;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (startTime.value > 0) {
        startTime.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOTP() {
    if (canResend.value) {
      otpDigits.value = ['', '', '', ''];
      startTimer();
    }
  }

  void updateDigit(int index, String value) {
    if (index >= 0 && index < 4) {
      otpDigits[index] = value;
      otpDigits.refresh();
    }
  }

  bool get isOTPComplete => !otpDigits.contains('');

  Future<void> verifyOTP() async {
    if (!isOTPComplete) return;
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    SuccessDialog.show("Your password has been \nupdated successfully.");
  }
}
