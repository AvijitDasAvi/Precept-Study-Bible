import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/response_data.dart';
import '../../routes/app_routes.dart';

class NetworkCaller {
  final int timeoutDuration = 10;

  // GET method
  Future<ResponseData> getRequest(String url, {String? token}) async {
    log('GET Request: $url');
    log('GET Token: $token');
    try {
      final http.Response response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': token.toString(),
              'Content-type': 'application/json',
            },
          )
          .timeout(Duration(seconds: timeoutDuration));

      return await _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST method
  Future<ResponseData> postRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    log('POST Token: $token');

    try {
      final headers = {'Content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token.toString();
      }

      final http.Response response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: timeoutDuration));
      return await _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT method
  Future<ResponseData> putRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PUT Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    log('PUT Token: $token');

    try {
      final headers = {'Content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token.toString();
      }

      final http.Response response = await http
          .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: timeoutDuration));
      return await _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PATCH method
  Future<ResponseData> patchRequest(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PATCH Request: $url');
    log('Request Body: ${jsonEncode(body)}');
    log('PATCH Token: $token');

    try {
      final headers = {'Content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token.toString();
      }

      final http.Response response = await http
          .patch(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(Duration(seconds: timeoutDuration));
      return await _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE method
  Future<ResponseData> deleteRequest(String url, {String? token}) async {
    log('DELETE Request: $url');
    log('DELETE Token: $token');
    try {
      final http.Response response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Authorization': token.toString(),
              'Content-type': 'application/json',
            },
          )
          .timeout(Duration(seconds: timeoutDuration));

      return await _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle response
  Future<ResponseData> _handleResponse(http.Response response) async {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    final decodedResponse = jsonDecode(response.body);

    // Handle 401 Unauthorized - Auto logout
    if (response.statusCode == 401) {
      try {
        // Only treat 401 as an expired session if we already have a stored access token.
        final prefs = await SharedPreferences.getInstance();
        final storedToken = prefs.getString('access_token') ?? '';

        if (storedToken.isNotEmpty) {
          // Existing token found -> this is likely an expired/invalid session
          _handleUnauthorized();
        }
      } catch (e) {
        log('Error checking stored token for 401 handling: $e');
      }

      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        // Forward server provided message when available (e.g., invalid credentials on login)
        errorMessage: decodedResponse['message'] ?? 'Unauthorized access',
      );
    }

    // Treat 200 and 201 as success responses
    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the API returns an explicit `success` flag use it
      if (decodedResponse is Map && decodedResponse.containsKey('success')) {
        if (decodedResponse['success'] == true) {
          return ResponseData(
            isSuccess: true,
            statusCode: response.statusCode,
            responseData: decodedResponse,
            errorMessage: '',
          );
        } else {
          return ResponseData(
            isSuccess: false,
            statusCode: response.statusCode,
            responseData: decodedResponse,
            errorMessage:
                decodedResponse['message'] ?? 'Unknown error occurred',
          );
        }
      }

      // If there's a message and the status code is 201 (created) treat it as success
      if (response.statusCode == 201 ||
          (decodedResponse is Map && decodedResponse['message'] != null)) {
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: '',
        );
      }

      // If the response is JSON data (Map or List) with content treat as success
      if (decodedResponse is Map && decodedResponse.isNotEmpty) {
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: '',
        );
      }

      if (decodedResponse is List && decodedResponse.isNotEmpty) {
        return ResponseData(
          isSuccess: true,
          statusCode: response.statusCode,
          responseData: decodedResponse,
          errorMessage: '',
        );
      }

      // Fallback: consider it an error with a message if provided
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: decodedResponse is Map
            ? (decodedResponse['message'] ?? 'Unknown error occurred')
            : 'Unknown error occurred',
      );
    } else if (response.statusCode == 400) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: _extractErrorMessages(decodedResponse['errorSources']),
      );
    } else if (response.statusCode == 500) {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: '',
        errorMessage:
            decodedResponse['message'] ?? 'An unexpected error occurred!',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: response.statusCode,
        responseData: decodedResponse,
        errorMessage: decodedResponse['message'] ?? 'An unknown error occurred',
      );
    }
  }

  // Extract error messages for status 400
  String _extractErrorMessages(dynamic errorSources) {
    if (errorSources is List) {
      return errorSources
          .map((error) => error['message'] ?? 'Unknown error')
          .join(', ');
    }
    return 'Validation error';
  }

  // Handle errors
  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');

    if (error is http.ClientException) {
      _checkOfflineMode();
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Network error occurred. Please check your connection.',
      );
    } else if (error is TimeoutException) {
      _checkOfflineMode();
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        responseData: '',
        errorMessage: 'Request timeout. Please try again later.',
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        responseData: '',
        errorMessage: 'Unexpected error occurred.',
      );
    }
  }

  // Check if user should enter offline mode
  Future<void> _checkOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      // If user has a token and network failed, redirect to downloads
      if (token.isNotEmpty) {
        Get.offAllNamed(AppRoute.getOfflineDownloadsScreen());
      }
    } catch (_) {}
  }

  // Handle unauthorized access (401)
  void _handleUnauthorized() async {
    try {
      // Clear the stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      // Navigate to sign-in screen
      Get.offAllNamed(AppRoute.getSignInScreen());

      // Show user-friendly message using EasyLoading
      EasyLoading.showError('Session expired. Please login again.');
    } catch (e) {
      log('Error handling unauthorized access: $e');
    }
  }
}
