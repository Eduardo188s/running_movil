// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUdE3s2n4ckmmThzM-fu6RD7chsJM5Kbw', // tu clave API web
    appId: '1:1038604616337:android:826c8ccd7561d701f87530', // App ID Android que me diste
    messagingSenderId: '1038604616337', // Número del proyecto que tienes (verifica si es el sender ID)
    projectId: 'running-3e33f',
    storageBucket: 'running-3e33f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS',
    appId: 'TU_APP_ID_IOS',
    messagingSenderId: 'TU_SENDER_ID_IOS',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_BUCKET_IOS.appspot.com',
    iosClientId: 'IOS_CLIENT_ID',
    iosBundleId: 'com.tuapp.ios',
  );
}
