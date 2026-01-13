import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/features/password_security/controller/password_security_controller.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordSecurityScreen extends StatelessWidget {
  PasswordSecurityScreen({super.key});

  final controller = Get.put(PasswordSecurityController());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final labelColor = isDarkMode ? Colors.grey[300]! : Colors.black;
    final inputBgColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final iconColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocalizationService.translate('password'),
          style: getTextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService.translate('old_password'),
                style: getTextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: labelColor,
                ),
              ),
              SizedBox(height: 10),
              Obx(
                () => TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: controller.oldObscure.value,
                  onChanged: (v) => controller.oldPassword.value = v,
                  validator: (v) => v!.isEmpty
                      ? LocalizationService.translate('enter_old_password')
                      : null,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBgColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.oldObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: iconColor,
                      ),
                      onPressed: controller.toggleOld,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                LocalizationService.translate('new_password'),
                style: getTextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: labelColor,
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: controller.newObscure.value,
                  onChanged: (v) => controller.newPassword.value = v,
                  validator: (v) => v!.length < 6
                      ? LocalizationService.translate('at_least_6_characters')
                      : null,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBgColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.newObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: iconColor,
                      ),
                      onPressed: controller.toggleNew,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                LocalizationService.translate('confirm_password'),
                style: getTextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: labelColor,
                ),
              ),
              SizedBox(height: 6),
              Obx(
                () => TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: controller.confirmObscure.value,
                  onChanged: (v) => controller.confirmPassword.value = v,
                  validator: (v) => v != controller.newPassword.value
                      ? LocalizationService.translate('password_not_match')
                      : null,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputBgColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.confirmObscure.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: iconColor,
                      ),
                      onPressed: controller.toggleConfirm,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Obx(
                () => Center(
                  child: SizedBox(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00228E),
                        padding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              LocalizationService.translate('save'),
                              style: getTextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
