// firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

const FirebaseOptions firebaseOptionsAndroid = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  projectId: 'sanctisync-application',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  messagingSenderId: '728673139082',
  appId: '1:728673139082:android:bf4e2be40b2c5f6576f073',
  measurementId: 'YOUR_MEASUREMENT_ID', // Remove this if you don’t need it
);

// For consistency, you may want to define iOS options if you ever expand to iOS.
