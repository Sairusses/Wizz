import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wizz/custom_widgets/task_card_member.dart';
import 'package:wizz/main_screens/home_screen.dart';
import 'package:wizz/role_selection/create_team.dart';
import 'package:wizz/services/firestore_service.dart';
import 'firebase_options.dart';

import 'package:wizz/role_selection/join_team.dart';
import 'package:wizz/role_selection/select_role_screen.dart';
import 'login_signup/login_screen.dart';
import 'member_screens/member_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );


  // runApp(
  //   MultiProvider(
  //       providers: [
  //         StreamProvider<QuerySnapshot?>.value(
  //           value: FirebaseFirestore.instance.collection('teams').snapshots(),
  //           initialData: null,
  //           catchError: (_, __) => null,
  //         ),
  //       ],
  //     child: Home(),
  //   )
  // );

  runApp(
      MultiProvider(
        providers: [
          StreamProvider<QuerySnapshot?>.value(
            value: FirebaseFirestore.instance.collection('teams').snapshots(),
            initialData: null,
            catchError: (_, __) => null,
          ),
        ],
        child: DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => Home()
        ),
      ),
  );

}


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      home: LoginScreen()
    );
  }
}


// class Home extends StatelessWidget {
//   const Home({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.light(),
//       home: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: LoginScreen(),
//       ),
//     );
//   }
// }