import 'package:calvinlockhart/core/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../../../core/utils/constants/colors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/routes/app_routes.dart';

class ProvideEmail extends StatefulWidget {
  const ProvideEmail({super.key});

  @override
  State<ProvideEmail> createState() => _ProvideEmailState();
}

class _ProvideEmailState extends State<ProvideEmail> {
  final TextEditingController _emailController = TextEditingController();
  final NetworkCaller _caller = NetworkCaller();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      EasyLoading.showError(LocalizationService.translate('invalid_email'));
      return;
    }

    EasyLoading.show();
    final res = await _caller.postRequest(
      ApiConstants.forgotPassword,
      body: {'email': email, 'type': 'PASSWORD_RESET'},
    );
    EasyLoading.dismiss();

    if (res.isSuccess) {
      EasyLoading.showSuccess(
        res.responseData is Map && res.responseData['message'] != null
            ? res.responseData['message'].toString()
            : LocalizationService.translate('otp_sent'),
      );
      Get.toNamed(
        AppRoute.getForgotPasswordVerify(),
        arguments: {'email': email},
      );
    } else {
      EasyLoading.showError(
        res.errorMessage.isNotEmpty
            ? res.errorMessage
            : LocalizationService.translate('otp_send_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: LocalizationService.localeNotifier,
        builder: (_, __, ___) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(top: 56, left: 20),
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                LocalizationService.translate('provide_email_title'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                LocalizationService.translate('provide_email_subtitle'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                LocalizationService.translate('email'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _emailController,
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
                    borderSide: BorderSide(color: Color(0xFF8AB5E3), width: 2),
                  ),
                  hintText: LocalizationService.translate('enter_your_email'),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: CustomButton(
                onTap: _sendCode,
                title: LocalizationService.translate('send_code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
