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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOz406oyWzjEMHlghknA2kZt6AjSIdPSM',
    appId: '1:686425174562:android:b75204e9cca846e849107b',
    messagingSenderId: '686425174562',
    projectId: 'techwiz-e0599',
    storageBucket: 'techwiz-e0599.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTxDxNQ1oP8VfufwlXr8KhkcQDXDKWtV4',
    appId: '1:686425174562:ios:1aa22bf27f3a534749107b',
    messagingSenderId: '686425174562',
    projectId: 'techwiz-e0599',
    storageBucket: 'techwiz-e0599.appspot.com',
    androidClientId: '686425174562-tgcj9uudmtvhoqp87jbbk1eroghvtj4d.apps.googleusercontent.com',
    iosClientId: '686425174562-i0sh3oheu39sehpul9b7fq8dce68gvkb.apps.googleusercontent.com',
    iosBundleId: 'com.example.techwiz5',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDs9GC-EXc87OwuYGLpR8nInJ-9D1ZVzNM',
    appId: '1:686425174562:web:24a9a383a79c4d8049107b',
    messagingSenderId: '686425174562',
    projectId: 'techwiz-e0599',
    authDomain: 'techwiz-e0599.firebaseapp.com',
    storageBucket: 'techwiz-e0599.appspot.com',
    measurementId: 'G-C6LMLQENHN',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTxDxNQ1oP8VfufwlXr8KhkcQDXDKWtV4',
    appId: '1:686425174562:ios:1aa22bf27f3a534749107b',
    messagingSenderId: '686425174562',
    projectId: 'techwiz-e0599',
    storageBucket: 'techwiz-e0599.appspot.com',
    androidClientId: '686425174562-tgcj9uudmtvhoqp87jbbk1eroghvtj4d.apps.googleusercontent.com',
    iosClientId: '686425174562-i0sh3oheu39sehpul9b7fq8dce68gvkb.apps.googleusercontent.com',
    iosBundleId: 'com.example.techwiz5',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDs9GC-EXc87OwuYGLpR8nInJ-9D1ZVzNM',
    appId: '1:686425174562:web:80fdc055f876597949107b',
    messagingSenderId: '686425174562',
    projectId: 'techwiz-e0599',
    authDomain: 'techwiz-e0599.firebaseapp.com',
    storageBucket: 'techwiz-e0599.appspot.com',
    measurementId: 'G-6LB77KGMMH',
  );

}