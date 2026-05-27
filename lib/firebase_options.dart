import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  // ── Reemplaza estos valores con los de tu proyecto Firebase ─────────────
  // Los encuentras en: Firebase Console → Configuración del proyecto

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY_AQUI',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    databaseURL: 'https://tu-proyecto-id-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS_AQUI',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    databaseURL: 'https://tu-proyecto-id-default-rtdb.firebaseio.com',
    iosClientId: 'TU_IOS_CLIENT_ID',
    iosBundleId: 'com.example.hotel',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TU_API_KEY_WEB_AQUI',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'tu-proyecto-id',
    storageBucket: 'tu-proyecto-id.appspot.com',
    databaseURL: 'https://tu-proyecto-id-default-rtdb.firebaseio.com',
    authDomain: 'tu-proyecto-id.firebaseapp.com',
  );
}
