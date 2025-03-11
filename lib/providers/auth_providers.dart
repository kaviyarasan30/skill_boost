import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_boost/models/user_model.dart';
import 'package:skill_boost/repositories/auth_repositories.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _error = '';
  UserModel? _currentUser;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _currentUser?.uid;
  bool get isLoading => _isLoading;
  String get error => _error;
  UserModel? get currentUser => _currentUser;

  // Initialize auth state on app startup
  Future<void> initAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await _repository.isLoggedIn();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _repository.login(email, password);

      if (result['success']) {
        _isAuthenticated = true;

        // Store the user data when login is successful
        if (result['user'] != null) {
          // Create a proper user model from the response
          _currentUser = UserModel(
            uid: result['user']['user_id'] ?? '',
            name: result['user']['user_name'] ?? '',
            email: result['user']['email'] ?? '',
            token: result['token'] ?? '',
            createdAt: result['user']['created_at'] != null
                ? DateTime.parse(result['user']['created_at'])
                : DateTime.now(),
          );

          // Save the token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', result['token']);
          await prefs.setString('userId', _currentUser!.uid);
        }
      } else {
        _error = result['error'];
      }

      _isLoading = false;
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String userName, String email, String password,
      String confirmPassword) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _repository.register(
          userName, email, password, confirmPassword);

      if (result['user'] != null) {
        _currentUser = UserModel(
          uid: result['user']['user_id'] ?? '',
          name: result['user']['user_name'] ?? '',
          email: result['user']['email'] ?? '',
          token: result['token'] ?? '',
          createdAt: result['user']['created_at'] != null
              ? DateTime.parse(result['user']['created_at'])
              : DateTime.now(),
        );

        // Save the token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        await prefs.setString('userId', _currentUser!.uid);
      } else {
        _error = result['error'];
      }

      _isLoading = false;
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  // Future<bool> resetPassword(String email) async {
  //   _isLoading = true;
  //   _error = '';
  //   notifyListeners();

  //   try {
  //     final result = await _repository.resetPassword(email);

  //     if (!result['success']) {
  //       _error = result['error'];
  //     }

  //     _isLoading = false;
  //     notifyListeners();
  //     return result['success'];
  //   } catch (e) {
  //     _isLoading = false;
  //     _error = e.toString();
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
