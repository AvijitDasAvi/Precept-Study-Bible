import 'package:calvinlockhart/features/auth/sign_in/screen/sign_in_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:calvinlockhart/core/models/response_data.dart';

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailError = ''.obs;
  final usernameError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final isLoading = false.obs;

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = LocalizationService.translate('email_empty');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      emailError.value = LocalizationService.translate('invalid_email');
    } else {
      emailError.value = '';
    }
  }

  void validateUsername(String value) {
    if (value.isEmpty) {
      usernameError.value = LocalizationService.translate('username_empty');
    } else if (value.length < 3) {
      usernameError.value = LocalizationService.translate(
        'username_min_length',
      );
    } else {
      usernameError.value = '';
    }
  }

  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = LocalizationService.translate('password_empty');
    } else if (value.length < 6) {
      passwordError.value = LocalizationService.translate(
        'password_min_length',
      );
    } else {
      passwordError.value = '';
      if (confirmPasswordController.text.isNotEmpty) {
        validateConfirmPassword(confirmPasswordController.text);
      }
    }
  }

  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      confirmPasswordError.value = LocalizationService.translate(
        'confirm_password_empty',
      );
    } else if (value != passwordController.text) {
      confirmPasswordError.value = LocalizationService.translate(
        'passwords_do_not_match',
      );
    } else {
      confirmPasswordError.value = '';
    }
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  void signUp() {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    validateConfirmPassword(confirmPasswordController.text);

    if (emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty) {
      _performSignUp();
    } else {
      EasyLoading.showError(LocalizationService.translate('form_fix_errors'));
    }
  }

  Future<void> _performSignUp() async {
    // isLoading.value = true;
    final caller = NetworkCaller();
    // EasyLoading.show();

    final body = {
      'email': emailController.text.trim(),
      'username': usernameController.text.trim(),
      'password': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
    };

    final ResponseData res = await caller.postRequest(
      ApiConstants.signUp,
      body: body,
    );

    // isLoading.value = false;

    if (res.isSuccess) {
      // EasyLoading.show();
      Get.to(SignInScreen()); //remove this line when OTP is enabled

      // final sendRes = await caller.postRequest(
      //   ApiConstants.sendOTP,
      //   body: {
      //     'email': emailController.text.trim(),
      //     'type': 'EMAIL_VERIFICATION',
      //   },
      // );

      // EasyLoading.dismiss();

      // if (sendRes.isSuccess) {
      //   EasyLoading.showSuccess(
      //     sendRes.responseData is Map && sendRes.responseData['message'] != null
      //         ? sendRes.responseData['message'].toString()
      //         : LocalizationService.translate('otp_sent'),
      //   );
      //   Get.back();
      //   Get.toNamed(
      //     '/auth/sign-up-verify',
      //     arguments: {'email': emailController.text.trim()},
      //   );
      // } else {
      //   String? apiMsg;
      //   if (sendRes.responseData is Map &&
      //       sendRes.responseData['message'] != null) {
      //     apiMsg = sendRes.responseData['message'].toString();
      //   }

      //   final msg = (apiMsg != null && apiMsg.isNotEmpty)
      //       ? apiMsg
      //       : (sendRes.errorMessage.isNotEmpty
      //             ? sendRes.errorMessage
      //             : LocalizationService.translate('otp_send_failed'));

      //   EasyLoading.showError(msg);
      // }
    } else {
      String? apiMessage;
      if (res.responseData is Map && res.responseData['message'] != null) {
        apiMessage = res.responseData['message'].toString();
      }

      final errorMsg = (apiMessage != null && apiMessage.isNotEmpty)
          ? apiMessage
          : (res.errorMessage.isNotEmpty
                ? res.errorMessage
                : LocalizationService.translate('error'));

      EasyLoading.dismiss();
      EasyLoading.showError(errorMsg);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    // usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
