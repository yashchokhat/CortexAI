// File generated for CortexAI Firebase configuration.
// Replace these with your project's credentials from the Firebase Console if needed.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCortexAI_WebDemoKey_Placeholder999',
    appId: '1:100000000000:web:cortexaiweb01',
    messagingSenderId: '100000000000',
    projectId: 'cortexai-app',
    authDomain: 'cortexai-app.firebaseapp.com',
    storageBucket: 'cortexai-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCortexAI_AndroidDemoKey_Placeholder888',
    appId: '1:100000000000:android:cortexaiandroid01',
    messagingSenderId: '100000000000',
    projectId: 'cortexai-app',
    storageBucket: 'cortexai-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCortexAI_iOSDemoKey_Placeholder777',
    appId: '1:100000000000:ios:cortexaiios01',
    messagingSenderId: '100000000000',
    projectId: 'cortexai-app',
    storageBucket: 'cortexai-app.appspot.com',
    iosBundleId: 'com.example.cortexaiApp',
  );
}
