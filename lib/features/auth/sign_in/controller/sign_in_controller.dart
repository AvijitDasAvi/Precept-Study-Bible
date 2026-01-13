import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/routes/app_routes.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final showPassword = false.obs;

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = LocalizationService.translate(
        'email_or_username_empty',
      );
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) &&
        value.length < 3) {
      emailError.value = LocalizationService.translate(
        'invalid_email_or_username',
      );
    } else {
      emailError.value = '';
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
    }
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email') ?? '';
      final savedPassword = prefs.getString('saved_password') ?? '';
      if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
      }
    } catch (_) {}
  }

  void signIn() {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);

    if (emailError.value.isEmpty && passwordError.value.isEmpty) {
      _performSignIn();
    } else {
      EasyLoading.showError(LocalizationService.translate('form_fix_errors'));
    }
  }

  Future<void> _performSignIn() async {
    EasyLoading.show(status: LocalizationService.translate('please_wait'));
    final caller = NetworkCaller();
    final body = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
    };

    final response = await caller.postRequest(ApiConstants.login, body: body);
    EasyLoading.dismiss();

    if (response.isSuccess) {
      final data = response.responseData as Map<String, dynamic>;
      final token = data['access_token'] ?? data['token'] ?? '';

      if (token != null && token.toString().isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        // Always persist access token, email, password and user info
        await prefs.setString('access_token', token.toString());
        await prefs.setString('saved_email', emailController.text.trim());
        await prefs.setString('saved_password', passwordController.text);
        final user = data['user'];
        if (user is Map) {
          await prefs.setString('user_email', user['email'] ?? '');
          await prefs.setString('user_id', user['id'] ?? '');
        }

        EasyLoading.showSuccess(LocalizationService.translate('login_success'));
        Get.offAllNamed(AppRoute.getNavbarScreen());
        return;
      }
      EasyLoading.showError(LocalizationService.translate('login_failed'));
    } else {
      EasyLoading.showError(response.errorMessage);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
