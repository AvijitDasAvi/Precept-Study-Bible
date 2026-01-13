import 'package:get/get.dart';

class AboutController extends GetxController {
  final texts = ["Legal", "Terms of Use", "Privacy Policy"].obs;

  var selectedIndex = (-1).obs;

  void onTextTap(int index) {
    selectedIndex.value = index;
  }
}
