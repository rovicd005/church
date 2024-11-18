import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return firebaseOptionsAndroid;
  }

  static const FirebaseOptions firebaseOptionsAndroid = FirebaseOptions(
    apiKey: "AIzaSyAjGCk4hq8TxjVQYqR2Nc6QsQukgqXsnqM",
    appId: "1:728673139082:android:bf4e2be40b2c5f6576f073",
    messagingSenderId: "728673139082",
    projectId: "sanctisync-application",
    databaseURL: "https://sanctisync-application-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "sanctisync-application.appspot.com",
  );
}