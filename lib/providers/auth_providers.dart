import 'package:flutter/foundation.dart';
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
        // If you have user data in the response, you can create a UserModel here
        // _currentUser = UserModel.fromMap(result['user']);
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

      if (result['success']) {
        _isAuthenticated = true;
        // If you have user data in the response, you can create a UserModel here
        // _currentUser = UserModel.fromMap(result['user']);
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
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _repository.resetPassword(email);

      if (!result['success']) {
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
