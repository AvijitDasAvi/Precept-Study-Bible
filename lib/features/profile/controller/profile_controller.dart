import 'package:calvinlockhart/core/utils/constants/image_path.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';

class ProfileController extends GetxController {
  var profileImage = ImagePath.profile.obs;

  var userName = ''.obs;
  var userEmail = "example@email.com".obs;

  final NetworkCaller _networkCaller = NetworkCaller();

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

      final response = await _networkCaller.getRequest(
        ApiConstants.userInfo,
        token: authHeader,
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'] ?? response.responseData;
        final email = data['email'] as String?;
        final firstName = data['firstName'] as String?;
        final lastName = data['lastName'] as String?;
        final avatar = data['userAvatar'] as String?;

        if (email != null && email.isNotEmpty) userEmail.value = email;

        final fn = (firstName ?? '').trim();
        final ln = (lastName ?? '').trim();
        if (fn.isNotEmpty || ln.isNotEmpty) {
          userName.value = [fn, ln].where((s) => s.isNotEmpty).join(' ');
        } else {
          userName.value = '';
        }

        if (avatar != null && avatar.isNotEmpty) {
          profileImage.value = avatar;
        } else {
          profileImage.value = ImagePath.profile;
        }
      }
    } catch (e) {
      // ignore errors silently for now
    }
  }
}
