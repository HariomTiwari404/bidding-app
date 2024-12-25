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
    apiKey: 'AIzaSyDMQeWeBqAvH1J4N7bIMhA3llcOW7RFEQ4',
    appId: '1:902206147921:web:054be75614585f80f65770',
    messagingSenderId: '902206147921',
    projectId: 'tenderbidding-86f71',
    authDomain: 'tenderbidding-86f71.firebaseapp.com',
    storageBucket: 'tenderbidding-86f71.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDS3mJTUW7XpAur8heTqphzJWtCTgpNG4M',
    appId: '1:902206147921:android:712c0aa5c1e8d251f65770',
    messagingSenderId: '902206147921',
    projectId: 'tenderbidding-86f71',
    storageBucket: 'tenderbidding-86f71.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9Da8YZTODhJAKyXanMV2UVODS6VGH_MA',
    appId: '1:902206147921:ios:0cb695e34ae4005bf65770',
    messagingSenderId: '902206147921',
    projectId: 'tenderbidding-86f71',
    storageBucket: 'tenderbidding-86f71.firebasestorage.app',
    iosBundleId: 'com.example.tenderBidding',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC9Da8YZTODhJAKyXanMV2UVODS6VGH_MA',
    appId: '1:902206147921:ios:0cb695e34ae4005bf65770',
    messagingSenderId: '902206147921',
    projectId: 'tenderbidding-86f71',
    storageBucket: 'tenderbidding-86f71.firebasestorage.app',
    iosBundleId: 'com.example.tenderBidding',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDMQeWeBqAvH1J4N7bIMhA3llcOW7RFEQ4',
    appId: '1:902206147921:web:fe7f634ed9c07ce2f65770',
    messagingSenderId: '902206147921',
    projectId: 'tenderbidding-86f71',
    authDomain: 'tenderbidding-86f71.firebaseapp.com',
    storageBucket: 'tenderbidding-86f71.firebasestorage.app',
  );
}
