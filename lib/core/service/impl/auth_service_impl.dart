import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_manager/model/user_model.dart';

import '../auth_service.dart';
import '../user_service.dart';

class AuthServiceImpl implements AuthService {
  GoogleSignInAccount? _googleUser;
  static User? _user;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserService _userService = UserService();

  AuthServiceImpl(this._auth, this._googleSignIn) {
    initializeGoogleSignIn();
  }

  @override
  Future<void> initializeGoogleSignIn() async {
    // Initialize and listen to authentication events
    await _googleSignIn.initialize(
        serverClientId: "50014509455-386katmd4i1l26u1dll42a6pr70m27i8.apps.googleusercontent.com"
    );

    _googleSignIn.authenticationEvents.listen((event) {
      _googleUser = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
    });
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Check if platform supports authenticate
      if (_googleSignIn.supportsAuthenticate()) {
        _googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
        final idToken = _googleUser?.authentication.idToken;
        final authorizationClient = _googleUser?.authorizationClient;
        GoogleSignInClientAuthorization? authorization =  await authorizationClient!.authorizationForScopes(['email', 'profile']);
        final accessToken =  authorization?.accessToken;
        if(accessToken == null){
          final authorization2 = await authorizationClient.authorizationForScopes(['email', 'profile']);
          if(authorization2?.accessToken == null){
            throw FirebaseAuthException(code: "error", message: "something went worng");
          }
          authorization = authorization2;
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken);
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        _user = userCredential.user;

      } else {
        // Handle web platform differently
        print('This platform requires platform-specific sign-in UI');
      }
      return _user;

    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure Firebase is initialized before this call
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = credentials.user;
      print("✅ User signed in: ${_user?.email}");
      return _user;
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.message}');
      return null;
    }
  }

  // Sign Up
  @override
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    String? familyId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _userService.createUser(
          userId: credential.user!.uid,
          email: email,
          familyId: familyId,
        );
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Registration Error: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}