// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7cq-oHq39fX9Pqv8IQEVdR1c88qW3q9Q',
    appId: '1:1092400608704:web:4179a29118fb9287820425',
    messagingSenderId: '1092400608704',
    projectId: 'test-5d050',
    authDomain: 'test-5d050.firebaseapp.com',
    storageBucket: 'test-5d050.firebasestorage.app',
    measurementId: 'G-K3RGQMG7EL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFd47A-dY27aQNrqv_XJwa-BACqKyZ5_0',
    appId: '1:1092400608704:android:a4f1500117ab51c1820425',
    messagingSenderId: '1092400608704',
    projectId: 'test-5d050',
    storageBucket: 'test-5d050.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeTu-h_Ng9XCHye-g2e74Fclr1KlZ-G0A',
    appId: '1:1092400608704:ios:fe22872df42e7db5820425',
    messagingSenderId: '1092400608704',
    projectId: 'test-5d050',
    storageBucket: 'test-5d050.firebasestorage.app',
    iosBundleId: 'com.example.smartTaskManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDeTu-h_Ng9XCHye-g2e74Fclr1KlZ-G0A',
    appId: '1:1092400608704:ios:fe22872df42e7db5820425',
    messagingSenderId: '1092400608704',
    projectId: 'test-5d050',
    storageBucket: 'test-5d050.firebasestorage.app',
    iosBundleId: 'com.example.smartTaskManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7cq-oHq39fX9Pqv8IQEVdR1c88qW3q9Q',
    appId: '1:1092400608704:web:f76cacdca77569f6820425',
    messagingSenderId: '1092400608704',
    projectId: 'test-5d050',
    authDomain: 'test-5d050.firebaseapp.com',
    storageBucket: 'test-5d050.firebasestorage.app',
    measurementId: 'G-C0ZY1CQV8X',
  );
}
