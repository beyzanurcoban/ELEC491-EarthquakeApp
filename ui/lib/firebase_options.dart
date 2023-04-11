// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAJwLAvtUiFfikXqb9pJWbA67aydG6fsZQ',
    appId: '1:820587352291:web:03edf8b5f8f198ed8ef5d6',
    messagingSenderId: '820587352291',
    projectId: 'nfc-earthquake',
    authDomain: 'nfc-earthquake.firebaseapp.com',
    storageBucket: 'nfc-earthquake.appspot.com',
    measurementId: 'G-VHLV81YFH5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBh2kraLxrYMPEydeFXA34Jv_FWjpDyS5Y',
    appId: '1:820587352291:android:af58df5331c788368ef5d6',
    messagingSenderId: '820587352291',
    projectId: 'nfc-earthquake',
    storageBucket: 'nfc-earthquake.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAspHN70k0AusOi3gs1t5uy8SKIvRf2MzQ',
    appId: '1:820587352291:ios:3d42936a2e30393a8ef5d6',
    messagingSenderId: '820587352291',
    projectId: 'nfc-earthquake',
    storageBucket: 'nfc-earthquake.appspot.com',
    iosClientId: '820587352291-nd8vm7adsrge4790d9fvsrm864lefc5m.apps.googleusercontent.com',
    iosBundleId: 'com.keremgirenes.ui',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAspHN70k0AusOi3gs1t5uy8SKIvRf2MzQ',
    appId: '1:820587352291:ios:3b69472e243801d48ef5d6',
    messagingSenderId: '820587352291',
    projectId: 'nfc-earthquake',
    storageBucket: 'nfc-earthquake.appspot.com',
    iosClientId: '820587352291-200plq0bhgrj7p62c4rvtcj4o741bcvb.apps.googleusercontent.com',
    iosBundleId: 'com.example.ui',
  );
}
