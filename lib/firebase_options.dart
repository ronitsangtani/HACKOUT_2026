import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Generated and configured for EcoLoop.
/// Run `flutterfire configure` to connect your active Firebase project.
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
    apiKey: 'AIzaSyEcoLoopWebApiKeyPlaceholder',
    appId: '1:100000000000:web:ecoloopwebid001',
    messagingSenderId: '100000000000',
    projectId: 'ecoloop-project',
    authDomain: 'ecoloop-project.firebaseapp.com',
    storageBucket: 'ecoloop-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfqyXZCHw-O7EZgJv-sd0nuD7GUiFQ7zE',
    appId: '1:701293503854:android:8798e3abc54b1adf8a8d7f',
    messagingSenderId: '701293503854',
    projectId: 'ecoloop-3fd3b',
    storageBucket: 'ecoloop-3fd3b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyEcoLoopIosApiKeyPlaceholder',
    appId: '1:100000000000:ios:ecoloopiosid001',
    messagingSenderId: '100000000000',
    projectId: 'ecoloop-project',
    storageBucket: 'ecoloop-project.appspot.com',
    iosBundleId: 'com.ecoloop.ecoloop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyEcoLoopIosApiKeyPlaceholder',
    appId: '1:100000000000:ios:ecoloopiosid001',
    messagingSenderId: '100000000000',
    projectId: 'ecoloop-project',
    storageBucket: 'ecoloop-project.appspot.com',
    iosBundleId: 'com.ecoloop.ecoloop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyEcoLoopWindowsApiKeyPlaceholder',
    appId: '1:100000000000:web:ecoloopwindowsid001',
    messagingSenderId: '100000000000',
    projectId: 'ecoloop-project',
    authDomain: 'ecoloop-project.firebaseapp.com',
    storageBucket: 'ecoloop-project.appspot.com',
  );
}
