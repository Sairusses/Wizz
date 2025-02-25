import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wizz/main_screens/home_screen.dart';
import 'firebase_options.dart';
import 'login_signup/login_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );

  runApp(
    DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => Home()
    ),
  );

  // runApp(Home());

}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: uid == null ? LoginScreen() : HomeScreen(),
      ),
    );
  }
}


// class Home extends StatelessWidget {
//   const Home({super.key});
//   @override
//   Widget build(BuildContext context) {
//     String? uid = FirebaseAuth.instance.currentUser?.uid;
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.light(),
//       home: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: uid == null ? LoginScreen() : HomeScreen(),
//       ),
//     );
//   }
// }