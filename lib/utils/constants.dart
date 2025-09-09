import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Expense Tracker';
  
  // Base URL detection - UPDATED FOR PHYSICAL DEVICES
  static String get baseUrl {
    if (kIsWeb) {
      // For web
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      try {
        // Simple check for emulator - this works on most devices
        final bool isEmulator = !Platform.environment.containsKey('ANDROID_ROOT') || 
                               Platform.environment['ANDROID_ROOT'] == null;
        
        if (isEmulator) {
          // Android emulator
          return 'http://10.0.2.2:3000/api';
        } else {
          // Android physical device - USE YOUR COMPUTER'S IP
          return 'http://192.168.1.100:3000/api'; // REPLACE WITH YOUR IP
        }
      } catch (e) {
        // Fallback for physical device
        return 'http://192.168.1.100:3000/api'; // REPLACE WITH YOUR IP
      }
    } else if (Platform.isIOS) {
      // For iOS - similar approach
      try {
        final result = Platform.environment;
        if (result.containsKey('SIMULATOR_DEVICE_NAME')) {
          // iOS simulator
          return 'http://localhost:3000/api';
        } else {
          // iOS physical device - USE YOUR COMPUTER'S IP
          return 'http://192.168.1.100:3000/api'; // REPLACE WITH YOUR IP
        }
      } catch (e) {
        // Fallback for physical device
        return 'http://192.168.1.100:3000/api'; // REPLACE WITH YOUR IP
      }
    }
    // Default for other platforms
    return 'http://localhost:3000/api';
  }
  
  // Helper method to get the current base URL (for debugging)
  static Future<String> getCurrentBaseUrl() async {
    return baseUrl;
  }
  
  // Shared Preferences Keys
  static const String isFirstTimeKey = 'isFirstTime';
  static const String authTokenKey = 'authToken';
  static const String userIdKey = 'userId';
  
  // MongoDB Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
}

class AppColors {
  static const primaryColor = Color(0xFF4CAF50);
  static const secondaryColor = Color(0xFF2196F3);
  static const accentColor = Color(0xFFFF9800);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color(0xFF333333);
  static const errorColor = Color(0xFFF44336);
}

class AppStrings {
  static const welcomeTitle = 'Welcome to Expense Tracker';
  static const welcomeSubtitle = 'Manage your finances easily';
  static const getStarted = 'Get Started';
  static const skip = 'Skip';
  static const next = 'Next';
  
  // Network error messages
  static const connectionError = 'Connection failed. Please check: \n1. Your computer and phone are on the same WiFi\n2. Your computer IP is correct: 192.168.1.100\n3. The backend server is running';
  static const serverError = 'Server connection failed';
}