import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configured for flutter-lab7-4df2f / flutter_application_srs7.
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
    apiKey: 'AIzaSyB4Vf9sVNmiN08fyrdD__VOsDUBj9AvNOw',
    appId: '1:663483170366:web:07df72f950026a60d8db6f',
    messagingSenderId: '663483170366',
    projectId: 'flutter-lab7-4df2f',
    authDomain: 'flutter-lab7-4df2f.firebaseapp.com',
    databaseURL: 'https://flutter-lab7-4df2f-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-lab7-4df2f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4Vf9sVNmiN08fyrdD__VOsDUBj9AvNOw',
    appId: '1:663483170366:android:07df72f950026a60d8db6f',
    messagingSenderId: '663483170366',
    projectId: 'flutter-lab7-4df2f',
    databaseURL: 'https://flutter-lab7-4df2f-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-lab7-4df2f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB4Vf9sVNmiN08fyrdD__VOsDUBj9AvNOw',
    appId: '1:663483170366:ios:07df72f950026a60d8db6f',
    messagingSenderId: '663483170366',
    projectId: 'flutter-lab7-4df2f',
    databaseURL: 'https://flutter-lab7-4df2f-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-lab7-4df2f.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationSrs7',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB4Vf9sVNmiN08fyrdD__VOsDUBj9AvNOw',
    appId: '1:663483170366:ios:07df72f950026a60d8db6f',
    messagingSenderId: '663483170366',
    projectId: 'flutter-lab7-4df2f',
    databaseURL: 'https://flutter-lab7-4df2f-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-lab7-4df2f.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationSrs7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB4Vf9sVNmiN08fyrdD__VOsDUBj9AvNOw',
    appId: '1:663483170366:web:07df72f950026a60d8db6f',
    messagingSenderId: '663483170366',
    projectId: 'flutter-lab7-4df2f',
    authDomain: 'flutter-lab7-4df2f.firebaseapp.com',
    databaseURL: 'https://flutter-lab7-4df2f-default-rtdb.firebaseio.com',
    storageBucket: 'flutter-lab7-4df2f.firebasestorage.app',
  );
}
