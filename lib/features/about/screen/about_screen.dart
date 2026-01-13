import 'package:calvinlockhart/features/about/controller/about_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "About",
              style: TextStyle(
                color: Color(0xFF21252C),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFE6E9F4),
          elevation: 0,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 26),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(controller.texts.length, (index) {
              bool hasDivider = (index == 0 || index == 1);
              return GestureDetector(
                onTap: () => controller.onTextTap(index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Text(
                        controller.texts[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: controller.selectedIndex.value == index
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: controller.selectedIndex.value == index
                              ? Colors.blue
                              : Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (hasDivider)
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(vertical: 8),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
