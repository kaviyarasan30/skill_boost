import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_boost/models/user_model.dart';

enum SignInResult {
  success,
  userNotFound,
  wrongPassword,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> initializeApp() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await getUserDetails(firebaseUser);
    }
  }

  Future<void> getUserDetails(User firebaseUser) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        _currentUser =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print("Error getting user details: $e");
    }
  }

  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check if the email exists in the users collection
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return SignInResult.userNotFound;
      }

      // Attempt to sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await getUserDetails(userCredential.user!);
      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return SignInResult.wrongPassword;
      } else {
        print("Error signing in: $e");
        return SignInResult.error;
      }
    } catch (e) {
      print("Error signing in: $e");
      return SignInResult.error;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String token = await userCredential.user!.getIdToken() ?? '';

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        token: token,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      _currentUser = newUser;
      notifyListeners();

      return true;
    } catch (e) {
      print("Error registering user: $e");
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
