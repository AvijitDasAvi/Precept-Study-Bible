import 'dart:async';
import 'package:flutter/material.dart';

class PreceptControllers {
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final List<Map<String, dynamic>> titleSuggestions = [];
  Timer? debounce;
  bool suppressTitleSuggestions = false;
  String? lastSelectedTitleText;
  String? preceptId;
  bool isMarkedForRemoval = false;

  void dispose() {
    title.dispose();
    description.dispose();
    debounce?.cancel();
  }
}
