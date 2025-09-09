import 'dart:convert';
import 'package:budget_buddy/models/user_profile.dart';
import 'package:budget_buddy/utils/constants.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/category.dart';
import 'session_manager.dart';

class DatabaseService {
  static final String baseUrl = AppConstants.baseUrl;
  final SessionManager _sessionManager = SessionManager();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _sessionManager.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Transaction methods
  Future<List<Transaction>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/transactions?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      // Add userId to transaction data
      final transactionData = transaction.toJson();
      transactionData['userId'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
        body: json.encode(transactionData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(String id, Transaction transaction) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      // Add userId to transaction data for security
      final transactionData = transaction.toJson();
      transactionData['userId'] = userId;
      
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: headers,
        body: json.encode(transactionData),
      );

      print('Update Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id?userId=$userId'),
        headers: headers,
      );

      print('DELETE Status: ${response.statusCode}');
      print('DELETE Response: ${response.body}');
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        print('Transaction not found on server');
        return false;
      } else if (response.statusCode == 401) {
        print('Unauthorized - check authentication');
        return false;
      } else {
        print('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error: $e');
      return false;
    }
  }

  // Category methods
  Future<List<Category>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      // Create category data with userId
      final categoryData = category.toJson();
      categoryData['userId'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
        body: json.encode(categoryData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  Future<bool> updateCategory(String id, Category category) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      // Add userId to category data
      final categoryData = category.toJson();
      categoryData['userId'] = userId;
      
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
        body: json.encode(categoryData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // User Profile methods
  Future<UserProfile> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        // Return default profile if not found
        return UserProfile(
          name: 'Your Name', 
          email: 'user@example.com',
          phone: '',
        );
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Return default profile on error
      return UserProfile(
        name: 'Your Name', 
        email: 'user@example.com',
        phone: '',
      );
    }
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final Map<String, dynamic> profileData = profile.toJson();
      profileData['userId'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  // Settings methods
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/settings?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        // Return default settings if not found
        return {
          'notificationsEnabled': true,
          'biometricsEnabled': false,
          'currency': 'USD',
          'themeMode': 'Light',
        };
      }
    } catch (e) {
      print('Error fetching settings: $e');
      // Return default settings on error
      return {
        'notificationsEnabled': true,
        'biometricsEnabled': false,
        'currency': 'USD',
        'themeMode': 'Light',
      };
    }
  }

  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final Map<String, dynamic> settingsData = Map.from(settings);
      settingsData['userId'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/settings'),
        headers: headers,
        body: json.encode(settingsData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  // Budget methods
  Future<Map<String, dynamic>> getBudget() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/budget?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'monthlyBudget': 0.0,
          'categories': {},
        };
      }
    } catch (e) {
      print('Error fetching budget: $e');
      return {
        'monthlyBudget': 0.0,
        'categories': {},
      };
    }
  }

  Future<bool> saveBudget(Map<String, dynamic> budget) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final Map<String, dynamic> budgetData = Map.from(budget);
      budgetData['userId'] = userId;
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/budget'),
        headers: headers,
        body: json.encode(budgetData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving budget: $e');
      return false;
    }
  }

  // Reports and analytics
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/reports/monthly?userId=$userId&year=$year&month=$month'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'income': 0.0,
          'expenses': 0.0,
          'balance': 0.0,
          'categories': {},
        };
      }
    } catch (e) {
      print('Error fetching monthly report: $e');
      return {
        'income': 0.0,
        'expenses': 0.0,
        'balance': 0.0,
        'categories': {},
      };
    }
  }

  Future<Map<String, dynamic>> getCategoryWiseReport() async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/reports/categories?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching category-wise report: $e');
      return {};
    }
  }

  // Get transactions by date range for reports
  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/date-range?userId=$userId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions by date range: $e');
      return [];
    }
  }

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/category?userId=$userId&categoryId=$categoryId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions by category: $e');
      return [];
    }
  }

  // Get transactions by type (income/expense)
  Future<List<Transaction>> getTransactionsByType(String type) async {
    try {
      final headers = await _getHeaders();
      final userId = await _sessionManager.getUserId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/type?userId=$userId&type=$type'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transactions by type: $e');
      return [];
    }
  }

  // Get default categories for new users
  Future<List<Category>> getDefaultCategories() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories/default'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching default categories: $e');
      return [];
    }
  }
}