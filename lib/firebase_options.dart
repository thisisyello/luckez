import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD43ml2VRCzv0INpfRt8L8Vdtl3i4PIvng',
    appId: '1:475615354311:web:9dface94db5152a1b40de2',
    messagingSenderId: '475615354311',
    projectId: 'luckez-9883e',
    authDomain: 'luckez-9883e.firebaseapp.com',
    storageBucket: 'luckez-9883e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJkz1FDBzmuBjVsbiK8Xg4blfEusTKecE',
    appId: '1:475615354311:android:518adf8730b23265b40de2',
    messagingSenderId: '475615354311',
    projectId: 'luckez-9883e',
    storageBucket: 'luckez-9883e.firebasestorage.app',
  );
}
