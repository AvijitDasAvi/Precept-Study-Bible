import 'package:get/get.dart';

class AccountSettingController extends GetxController {
  void goToInformationUpdate() {
    Get.toNamed('/informationUpdate');
  }

  void goToPasswordSecurity() {
    Get.toNamed('/passwordSecurityScreen');
  }
}
