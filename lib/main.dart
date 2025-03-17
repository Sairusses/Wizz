  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:device_preview_plus/device_preview_plus.dart';
  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:wizz/intro_slider.dart';
  import 'firebase_options.dart';
  import 'package:flutter/foundation.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true
    );
    // ignore: dead_code
    if(kReleaseMode){
      runApp(Home());
    // ignore: dead_code
    }else{
      runApp(
        DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => Home2()
        ),
      );
    }
  }

  class Home2 extends StatelessWidget {
    const Home2({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        home: IntroSlider()
      );
    }
  }


  class Home extends StatelessWidget {
    const Home({super.key});
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.blueAccent, // Cursor color
            selectionColor: Colors.blue.withOpacity(0.4), // Background color of selected text
            selectionHandleColor: Colors.blueAccent, // The handle color
          ),
          brightness: Brightness.light,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        home: IntroSlider()
      );
    }
  }