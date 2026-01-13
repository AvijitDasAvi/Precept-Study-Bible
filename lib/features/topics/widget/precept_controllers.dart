import 'dart:async';
import 'package:flutter/material.dart';

class PreceptControllers {
  final TextEditingController title;
  final TextEditingController description;
  Timer? debounceTimer;
  List<Map<String, dynamic>> titleSuggestions = [];

  PreceptControllers({
    TextEditingController? title,
    TextEditingController? description,
  }) : title = title ?? TextEditingController(),
       description = description ?? TextEditingController();

  void dispose() {
    title.dispose();
    description.dispose();
    debounceTimer?.cancel();
  }
}
