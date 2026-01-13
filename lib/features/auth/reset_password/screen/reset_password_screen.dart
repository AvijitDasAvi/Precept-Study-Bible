import 'package:calvinlockhart/core/common/widgets/custom_app_bar.dart';
import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/features/auth/reset_password/controller/reset_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final ResetPasswordController controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.back(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                LocalizationService.translate('reset_password'),
                textAlign: TextAlign.center,
                style: getTextStyle(
                  color: Color(0xFF21252C),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                LocalizationService.translate('reset_password_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2B303A),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.translate('new_password'),
                    style: TextStyle(
                      color: Color(0xFF005EC2),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 3),
                  Obx(
                    () => TextFormField(
                      controller: controller.newPasswordController,
                      obscureText: controller.newPasswordObscure.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: controller.validateNewPassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFDFEFF),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.newPasswordObscure.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xFF8AB5E3),
                            size: 20,
                          ),
                          onPressed: controller.toggleNewPasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    LocalizationService.translate('confirm_password'),
                    style: TextStyle(
                      color: Color(0xFF005EC2),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 3),
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.confirmPasswordObscure.value,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: controller.validateConfirmPassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFDFEFF),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.confirmPasswordObscure.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Color(0xFF8AB5E3),
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00228E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Color(0x47005EC2),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            LocalizationService.translate('reset_password'),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}
