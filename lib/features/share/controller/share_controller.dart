import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ShareController extends GetxController {
  var installCount = 974_405_331.obs;

  void shareApp() {
    final formattedCount = NumberFormat('#,###').format(installCount.value);

    final message =
        "Join me in spreading God's word! "
        "Total installs: $formattedCount";

    // ignore: deprecated_member_use
    Share.share(message);
  }
}
