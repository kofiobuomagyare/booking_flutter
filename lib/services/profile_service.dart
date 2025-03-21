import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  // ✅ Corrected baseUrl assignment
  final String baseUrl = getBaseUrl();

  static String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080';
    }
    return 'http://your-production-api-url.com';
  }

  Future<Map<String, dynamic>> getUserProfile(String email) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/profile/$email")); // ✅ Use `/api/profile/{email}`

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception("User not found.");
      } else {
        throw Exception("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      } // ✅ Debugging log
      return {}; // ✅ Return an empty map instead of crashing the app
    }
  }
}
