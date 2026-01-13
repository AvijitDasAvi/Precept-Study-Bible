import 'dart:io';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calvinlockhart/features/profile/controller/profile_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class InformationUpdateController extends GetxController {
  final NetworkCaller _caller = NetworkCaller();

  final firstName = ''.obs;
  final lastName = ''.obs;
  final email = ''.obs;
  final bio = ''.obs;
  final avatarUrl = ''.obs;
  File? pickedImageFile;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final res = await _caller.getRequest(
        ApiConstants.userInfo,
        token: authHeader,
      );

      if (res.isSuccess && res.responseData != null) {
        final data = res.responseData['data'] ?? res.responseData;
        firstName.value = (data['firstName'] ?? '').toString();
        lastName.value = (data['lastName'] ?? '').toString();
        email.value = (data['email'] ?? '').toString();
        bio.value = (data['bio'] ?? '').toString();
        avatarUrl.value = (data['userAvatar'] ?? '').toString();

        firstNameController.text = firstName.value;
        lastNameController.text = lastName.value;
        emailController.text = email.value;
        bioController.text = bio.value;
        update();
      }
    } catch (e) {
      // ignore
    }
  }

  void updateFirstName(String v) => firstName.value = v;
  void updateLastName(String v) => lastName.value = v;
  void updateEmail(String v) => email.value = v;
  void updateBio(String v) => bio.value = v;

  Future<void> pickImage() async {
    try {
      final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);
      if (xfile != null) {
        pickedImageFile = File(xfile.path);
        update();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> saveInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      EasyLoading.show();

      if (pickedImageFile != null) {
        try {
          final uri = Uri.parse(ApiConstants.updateUser);
          final request = http.MultipartRequest('PUT', uri);
          if (authHeader.isNotEmpty) {
            request.headers['Authorization'] = authHeader;
          }
          request.fields['firstName'] = firstNameController.text.trim();
          request.fields['lastName'] = lastNameController.text.trim();
          request.fields['bio'] = bioController.text.trim();
          request.files.add(
            await http.MultipartFile.fromPath('file', pickedImageFile!.path),
          );

          final streamed = await request.send();
          final resp = await http.Response.fromStream(streamed);
          debugPrint('Multipart update status: ${resp.statusCode}');
          debugPrint('Multipart update body: ${resp.body}');

          EasyLoading.dismiss();

          final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
          if (resp.statusCode == 200 || resp.statusCode == 201) {
            EasyLoading.showSuccess(
              decoded is Map && decoded['message'] != null
                  ? decoded['message'].toString()
                  : LocalizationService.translate(
                      'information_saved_successfully',
                    ),
            );

            final data = decoded != null && decoded is Map
                ? (decoded['data'] ?? decoded)
                : {};
            firstName.value = (data['firstName'] ?? '').toString();
            lastName.value = (data['lastName'] ?? '').toString();
            bio.value = (data['bio'] ?? '').toString();
            avatarUrl.value = (data['userAvatar'] ?? '').toString();

            firstNameController.text = firstName.value;
            lastNameController.text = lastName.value;
            bioController.text = bio.value;
            update();
            // Refresh profile screen data if controller is registered
            try {
              if (Get.isRegistered<ProfileController>()) {
                final profileController = Get.find<ProfileController>();
                profileController.fetchUserInfo();
              }
            } catch (_) {}
          } else {
            final errMsg = (decoded is Map && decoded['message'] != null)
                ? (decoded['message'].toString())
                : 'Update failed';
            EasyLoading.showError(errMsg);
          }
          return;
        } catch (e) {
          EasyLoading.dismiss();
          debugPrint('Multipart update error: $e');
          EasyLoading.showError('Update failed');
          return;
        }
      }

      final body = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'bio': bioController.text.trim(),
        'userAvatar': avatarUrl.value.isNotEmpty ? avatarUrl.value : null,
      };

      final res = await _caller.putRequest(
        ApiConstants.updateUser,
        body: body,
        token: authHeader.isNotEmpty ? authHeader : null,
      );

      EasyLoading.dismiss();

      if (res.isSuccess) {
        EasyLoading.showSuccess(
          res.responseData is Map && res.responseData['message'] != null
              ? res.responseData['message'].toString()
              : LocalizationService.translate('information_saved_successfully'),
        );
        final data = res.responseData['data'] ?? res.responseData;
        firstName.value = (data['firstName'] ?? '').toString();
        lastName.value = (data['lastName'] ?? '').toString();
        bio.value = (data['bio'] ?? '').toString();
        avatarUrl.value = (data['userAvatar'] ?? '').toString();

        firstNameController.text = firstName.value;
        lastNameController.text = lastName.value;
        bioController.text = bio.value;
        update();
        // Refresh profile screen data if controller is registered
        try {
          if (Get.isRegistered<ProfileController>()) {
            final profileController = Get.find<ProfileController>();
            profileController.fetchUserInfo();
          }
        } catch (_) {}
      } else {
        EasyLoading.showError(
          res.errorMessage.isNotEmpty ? res.errorMessage : 'Update failed',
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Unexpected error');
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
