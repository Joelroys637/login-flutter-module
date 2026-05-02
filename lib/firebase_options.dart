import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAZi7PdktU6RboZygDGCWXrFbHx7eBybT8',
    appId: '1:1029739904193:web:a4c07b0db18eff2f78e840', // Fallback web ID based on Android ID
    messagingSenderId: '1029739904193',
    projectId: 'flutter-login-532ee',
    authDomain: 'flutter-login-532ee.firebaseapp.com',
    storageBucket: 'flutter-login-532ee.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZi7PdktU6RboZygDGCWXrFbHx7eBybT8',
    appId: '1:1029739904193:android:a4c07b0db18eff2f78e840',
    messagingSenderId: '1029739904193',
    projectId: 'flutter-login-532ee',
    storageBucket: 'flutter-login-532ee.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZi7PdktU6RboZygDGCWXrFbHx7eBybT8',
    appId: '1:1029739904193:ios:a4c07b0db18eff2f78e840', // Fallback iOS ID
    messagingSenderId: '1029739904193',
    projectId: 'flutter-login-532ee',
    storageBucket: 'flutter-login-532ee.firebasestorage.app',
    iosBundleId: 'leo.login',
  );
}
