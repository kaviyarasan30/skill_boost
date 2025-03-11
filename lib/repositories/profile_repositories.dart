import 'package:skill_boost/api/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      return await _profileService.getUserDetails(userId);
    } catch (e) {
      return {
        'success': false,
        'error': 'Error fetching user details: $e',
      };
    }
  }
}