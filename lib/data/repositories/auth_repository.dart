import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    // logs
    await _auth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
        
        // Optional: Force account selection even when one account is available
        googleProvider.setCustomParameters({
          'prompt': 'select_account'
        });
        
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile implementation
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
          clientId: Platform.isIOS ? '1092400608704-nbbiieko3tfkkv419q0m0cj353k0fqv8.apps.googleusercontent.com' : null,
        );

        final googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        }
        
        final googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken == null) {
          throw FirebaseAuthException(
            code: 'ERROR_MISSING_ACCESS_TOKEN',
            message: 'Missing Google Access Token',
          );
        }

        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'ERROR_MISSING_ID_TOKEN',
            message: 'Missing Google ID Token',
          );
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: 'ERROR_GOOGLE_SIGN_IN_FAILED',
        message: 'Google sign in failed: ${e.toString()}',
      );
    }
  }
}
