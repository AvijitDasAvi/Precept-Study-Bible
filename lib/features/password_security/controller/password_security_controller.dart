import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';

class PasswordSecurityController extends GetxController {
  var oldPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  var oldObscure = true.obs;
  var newObscure = true.obs;
  var confirmObscure = true.obs;

  var isLoading = false.obs;

  final formKey = GlobalKey<FormState>();
  final NetworkCaller _caller = NetworkCaller();

  void toggleOld() => oldObscure.value = !oldObscure.value;
  void toggleNew() => newObscure.value = !newObscure.value;
  void toggleConfirm() => confirmObscure.value = !confirmObscure.value;

  Future<void> savePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final body = {
        'oldPassword': oldPassword.value,
        'newPassword': newPassword.value,
        'confirmPassword': confirmPassword.value,
      };

      final response = await _caller.postRequest(
        ApiConstants.resetPassword,
        body: body,
        token: token.isNotEmpty ? 'Bearer $token' : null,
      );

      isLoading.value = false;

      if (response.isSuccess) {
        final msg = (response.responseData is Map)
            ? (response.responseData['message'] ?? 'Password updated')
            : 'Password updated';
        EasyLoading.showSuccess(msg);
      } else {
        EasyLoading.showError(response.errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      EasyLoading.showError('An unexpected error occurred');
    }
  }
}
