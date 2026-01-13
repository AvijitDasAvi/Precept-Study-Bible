import 'package:calvinlockhart/core/common/widgets/custom_button.dart';
import 'package:calvinlockhart/core/utils/constants/colors.dart';
import 'package:calvinlockhart/features/auth/sign_in/controller/sign_in_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: LocalizationService.localeNotifier,
        builder: (_, __, ___) => SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 88),
                width: double.infinity,
                height: 206,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      LocalizationService.translate('welcome_back'),
                      style: TextStyle(
                        color: Color(0xFFE6EFF9),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      LocalizationService.translate('signin_subtitle'),
                      style: TextStyle(
                        color: Color(0xFFEDEEF0),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 42),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.translate('email_username'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      controller: controller.emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF8AB5E3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF8AB5E3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xFF8AB5E3),
                            width: 2,
                          ),
                        ),
                        hintText: LocalizationService.translate(
                          'enter_email_username',
                        ),
                        errorText: controller.emailError.value.isEmpty
                            ? null
                            : controller.emailError.value,
                      ),
                      onChanged: (value) => controller.validateEmail(value),
                    ),
                    SizedBox(height: 20),
                    Text(
                      LocalizationService.translate('password'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Obx(
                      () => TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.showPassword.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF8AB5E3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF8AB5E3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF8AB5E3),
                              width: 2,
                            ),
                          ),
                          hintText: LocalizationService.translate(
                            'enter_password',
                          ),
                          errorText: controller.passwordError.value.isEmpty
                              ? null
                              : controller.passwordError.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color(0xFF8AB5E3),
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        onChanged: (value) =>
                            controller.validatePassword(value),
                      ),
                    ),
                    // SizedBox(height: 20),
                    // Row(
                    //   children: [
                    //     Spacer(),
                    //     GestureDetector(
                    //       onTap: () {
                    //         Get.toNamed('/provideEmail');
                    //       },
                    //       child: Text(
                    //         LocalizationService.translate('forgot_password'),
                    //         style: TextStyle(
                    //           color: Color(0xFFFF3636),
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 30),
                    Center(
                      child: CustomButton(
                        onTap: controller.signIn,
                        title: LocalizationService.translate('sign_in'),
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: LocalizationService.translate(
                            'dont_have_account',
                          ),
                          style: TextStyle(
                            color: Color(0xFF4F5869),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: LocalizationService.translate('sign_up'),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed('/signUpScreen');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
