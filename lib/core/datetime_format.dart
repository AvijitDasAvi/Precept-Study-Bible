import 'package:intl/intl.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class DatetimeFormat {
  String formatDateTimeWithDifference(dynamic dateTime) {
    if (dateTime == null) return LocalizationService.translate('invalid_date');

    DateTime parsedDate = dateTime is DateTime
        ? dateTime
        : DateTime.tryParse(dateTime.toString()) ?? DateTime.now();

    Duration difference = DateTime.now().difference(parsedDate);
    if (difference.isNegative) {
      difference = difference.abs();
    }

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} ${LocalizationService.translate('second')}${difference.inSeconds > 1 ? 's' : ''} ${LocalizationService.translate('ago')}';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${LocalizationService.translate('minute')}${difference.inMinutes > 1 ? 's' : ''} ${LocalizationService.translate('ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${LocalizationService.translate('hour')}${difference.inHours > 1 ? 's' : ''} ${LocalizationService.translate('ago')}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${LocalizationService.translate('day')}${difference.inDays > 1 ? 's' : ''} ${LocalizationService.translate('ago')}';
    } else {
      final DateFormat formatter = DateFormat('dd MMMM yyyy');
      return formatter.format(parsedDate);
    }
  }

  /// Formats UTC datetime to local time in format: MM/dd/yyyy hh:mm a
  /// Example: 12/25/2024 3:45 PM
  static String formatUtcToLocal(dynamic dateTime) {
    if (dateTime == null) return '';

    try {
      DateTime parsedDate;
      if (dateTime is DateTime) {
        parsedDate = dateTime;
      } else {
        parsedDate = DateTime.tryParse(dateTime.toString()) ?? DateTime.now();
      }

      // Convert UTC to local time
      final localDateTime = parsedDate.toLocal();

      // Format as MM/dd/yyyy hh:mm a
      final DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm a');
      return formatter.format(localDateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
