import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/utils/constants/icon_path.dart';
import 'package:calvinlockhart/core/utils/constants/image_path.dart';
import 'package:calvinlockhart/features/information_update/controller/information_update_controller.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InformationUpdateScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(InformationUpdateController());

  InformationUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final labelColor = isDarkMode ? Colors.grey[300]! : Colors.black;
    final fillColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final hintColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocalizationService.translate('information'),
          style: getTextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 15),
              GetBuilder<InformationUpdateController>(
                builder: (c) {
                  final ImageProvider<Object> avatar =
                      _informationAvatarImageProvider(
                        c.pickedImageFile,
                        c.avatarUrl.value,
                      );

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(radius: 48, backgroundImage: avatar),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () => c.pickImage(),
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              IconPath.camera,
                              height: 26,
                              width: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                LocalizationService.translate('click_to_update'),
                style: getTextStyle(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 65),
              _buildLabeledField(
                LocalizationService.translate('first_name'),
                controller.firstNameController,
                onChanged: controller.updateFirstName,
                isDarkMode: isDarkMode,
                labelColor: labelColor,
                fillColor: fillColor,
                hintColor: hintColor,
              ),
              SizedBox(height: 15),
              _buildLabeledField(
                LocalizationService.translate('last_name'),
                controller.lastNameController,
                onChanged: controller.updateLastName,
                isDarkMode: isDarkMode,
                labelColor: labelColor,
                fillColor: fillColor,
                hintColor: hintColor,
              ),
              SizedBox(height: 15),
              _buildLabeledField(
                LocalizationService.translate('email_address'),
                controller.emailController,
                readOnly: true,
                isDarkMode: isDarkMode,
                labelColor: labelColor,
                fillColor: fillColor,
                hintColor: hintColor,
              ),
              SizedBox(height: 15),
              _buildLabeledField(
                LocalizationService.translate('bio'),
                controller.bioController,
                onChanged: controller.updateBio,
                maxLines: 3,
                isDarkMode: isDarkMode,
                labelColor: labelColor,
                fillColor: fillColor,
                hintColor: hintColor,
              ),
              SizedBox(height: 25),
              SizedBox(
                width: 110,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00228E),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.saveInfo();
                    }
                  },
                  child: Text(
                    LocalizationService.translate('save'),
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildLabeledField(
    String label,
    TextEditingController fieldController, {
    Function(String)? onChanged,
    bool readOnly = false,
    int maxLines = 1,
    required bool isDarkMode,
    required Color? labelColor,
    required Color? fillColor,
    required Color? hintColor,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: labelColor ?? Colors.black,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: fieldController,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(color: hintColor),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

ImageProvider<Object> _informationAvatarImageProvider(
  dynamic pickedFile,
  String url,
) {
  try {
    if (pickedFile != null) {
      return FileImage(pickedFile) as ImageProvider<Object>;
    }
  } catch (_) {}

  final trimmed = url.trim();
  if (trimmed.isNotEmpty &&
      (trimmed.startsWith('http://') || trimmed.startsWith('https://'))) {
    return NetworkImage(trimmed) as ImageProvider<Object>;
  }

  return AssetImage(ImagePath.profile) as ImageProvider<Object>;
}
