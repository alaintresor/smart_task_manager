import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      // Configure sign-in
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
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
