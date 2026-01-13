import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/utils/localization/localization_service.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newPasswordObscure = true.obs;
  final confirmPasswordObscure = true.obs;
  final isLoading = false.obs;

  final NetworkCaller _caller = NetworkCaller();

  void toggleNewPasswordVisibility() {
    newPasswordObscure.value = !newPasswordObscure.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordObscure.value = !confirmPasswordObscure.value;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationService.translate('password_empty');
    }
    if (value.length < 6) {
      return LocalizationService.translate('password_min_length');
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationService.translate('password_empty');
    }
    if (value != newPasswordController.text) {
      return LocalizationService.translate('password_not_match');
    }
    return null;
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    final email = Get.arguments != null && Get.arguments['email'] != null
        ? Get.arguments['email'].toString()
        : '';

    final resetToken =
        Get.arguments != null && Get.arguments['resetToken'] != null
        ? Get.arguments['resetToken'].toString()
        : '';

    if (email.isEmpty && resetToken.isEmpty) {
      EasyLoading.showError(LocalizationService.translate('invalid_request'));
      return;
    }

    isLoading.value = true;
    EasyLoading.show(status: LocalizationService.translate('please_wait'));

    try {
      Map<String, String> body;
      String? tokenHeader;
      if (resetToken.isNotEmpty) {
        tokenHeader = 'Bearer $resetToken';
        body = {
          'newPassword': newPasswordController.text,
          'confirmPassword': confirmPasswordController.text,
        };
      } else {
        body = {
          'email': email,
          'newPassword': newPasswordController.text,
          'confirmPassword': confirmPasswordController.text,
        };
      }

      final response = await _caller.postRequest(
        ApiConstants.setNewPassword,
        body: body,
        token: tokenHeader,
      );

      isLoading.value = false;
      EasyLoading.dismiss();

      if (response.isSuccess) {
        final message =
            response.responseData is Map &&
                response.responseData['message'] != null
            ? response.responseData['message'].toString()
            : LocalizationService.translate('password_reset_success');

        EasyLoading.showSuccess(message);
        Get.offAllNamed('/signInScreen');
      } else {
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : LocalizationService.translate('password_reset_failed'),
        );
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showError(LocalizationService.translate('unexpected_error'));
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
