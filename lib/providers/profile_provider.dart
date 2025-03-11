import 'package:flutter/foundation.dart';
import 'package:skill_boost/repositories/profile_repositories.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get userProfile => _userProfile;

  // Get user details
  Future<void> getUserDetails(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _repository.getUserDetails(userId);

      if (result['success']) {
        _userProfile = result['user'];
      } else {
        _error = result['error'];
      }

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

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}
