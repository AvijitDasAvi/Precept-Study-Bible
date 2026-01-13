import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class ForgotPasswordVerifyController extends GetxController {
  final code = List<String>.filled(4, '').obs;
  final timerSeconds = 60.obs;
  Timer? _timer;
  final isVerifying = false.obs;
  late final List<TextEditingController> digitControllers;
  late final List<FocusNode> digitFocusNodes;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    digitControllers = List.generate(4, (_) => TextEditingController());
    digitFocusNodes = List.generate(4, (_) => FocusNode());
  }

  void _startTimer() {
    timerSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        t.cancel();
      }
    });
  }

  void resendCode() {
    final email = Get.arguments != null && Get.arguments['email'] != null
        ? Get.arguments['email'].toString()
        : '';

    if (email.isEmpty) {
      EasyLoading.showError(LocalizationService.translate('invalid_email'));
      return;
    }

    final caller = NetworkCaller();
    EasyLoading.show();
    caller
        .postRequest(
          ApiConstants.sendOTP,
          body: {'email': email, 'type': 'FORGOT_PASSWORD'},
        )
        .then((res) {
          EasyLoading.dismiss();
          if (res.isSuccess) {
            EasyLoading.showSuccess(
              res.responseData is Map && res.responseData['message'] != null
                  ? res.responseData['message'].toString()
                  : LocalizationService.translate('otp_sent'),
            );
            _startTimer();
          } else {
            String? apiMsg;
            if (res.responseData is Map &&
                res.responseData['message'] != null) {
              apiMsg = res.responseData['message'].toString();
            }

            final msg = (apiMsg != null && apiMsg.isNotEmpty)
                ? apiMsg
                : (res.errorMessage.isNotEmpty
                      ? res.errorMessage
                      : LocalizationService.translate('otp_send_failed'));

            EasyLoading.showError(msg);
          }
        });
  }

  String get enteredCode => code.join();

  void updateDigit(int index, String val) {
    if (index < 0 || index > 3) return;
    code[index] = val;
    code.refresh();
  }

  void onDigitEntered(int index, String val) {
    if (val.isEmpty) {
      code[index] = '';
      code.refresh();
      if (index > 0) digitFocusNodes[index - 1].requestFocus();
      return;
    }

    final ch = val.substring(val.length - 1);
    code[index] = ch;
    digitControllers[index].text = ch;
    code.refresh();

    if (index < digitFocusNodes.length - 1) {
      digitFocusNodes[index + 1].requestFocus();
    } else {
      digitFocusNodes[index].unfocus();
    }
  }

  Future<bool> verifyCode() async {
    final email = Get.arguments != null && Get.arguments['email'] != null
        ? Get.arguments['email'].toString()
        : '';

    if (email.isEmpty) {
      EasyLoading.showError(LocalizationService.translate('invalid_email'));
      return false;
    }

    if (enteredCode.isEmpty) {
      EasyLoading.showError(LocalizationService.translate('invalid_otp'));
      return false;
    }

    isVerifying.value = true;
    EasyLoading.show();

    final caller = NetworkCaller();

    var res = await caller.postRequest(
      ApiConstants.verifyForgotPasswordOTP,
      body: {'email': email, 'code': enteredCode, 'type': 'PASSWORD_RESET'},
    );

    if (!res.isSuccess && res.statusCode == 404) {
      res = await caller.postRequest(
        ApiConstants.verifyOTP,
        body: {'email': email, 'code': enteredCode, 'type': 'PASSWORD_RESET'},
      );
    }

    EasyLoading.dismiss();
    isVerifying.value = false;

    if (res.isSuccess) {
      final resetToken =
          res.responseData is Map && res.responseData['resetToken'] != null
          ? res.responseData['resetToken'].toString()
          : '';

      EasyLoading.showSuccess(LocalizationService.translate('otp_verified'));

      final args = <String, String>{'email': email};
      if (resetToken.isNotEmpty) args['resetToken'] = resetToken;

      Get.toNamed('/auth/reset-password', arguments: args);
      return true;
    }

    String? apiMsg;
    if (res.responseData is Map && res.responseData['message'] != null) {
      apiMsg = res.responseData['message'].toString();
    }

    final msg = (apiMsg != null && apiMsg.isNotEmpty)
        ? apiMsg
        : (res.errorMessage.isNotEmpty
              ? res.errorMessage
              : LocalizationService.translate('invalid_otp'));

    EasyLoading.showError(msg);
    return false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final c in digitControllers) {
      c.dispose();
    }
    for (final f in digitFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
