import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/firebase_options.dart';
import 'package:entrema/home/home.dart';
import 'package:entrema/start/welcome.dart';
import 'package:entrema/widget/Loader.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true, // enable offline persistence
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    _auth = auth.FirebaseAuth.instance;
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: const [Locale('en'), Locale('fr')],
        title: "Entr'EMA",
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
          useMaterial3: true,
          textTheme: const TextTheme().apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
          primarySwatch: Colors.blue,
          primaryColor: Colors.white,
          primaryColorDark: Colors.black,
          canvasColor: const Color.fromARGB(255, 244, 246, 246),
          fontFamily: "Cocogoose",
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
            fontFamily: 'Cocogoose',
            canvasColor: const Color(0xff111111),
            brightness: Brightness.dark,
            primaryColorDark: Colors.white,
            primaryColor: Colors.black,
            primaryColorLight: Colors.black),
        home: FutureBuilder<User?>(
          future: getUser(),
          builder: (BuildContext context, userTemp) {
            if (userTemp.hasData ||
                userTemp.connectionState == ConnectionState.done) {
              User? user = userTemp.data;
              if (user != null && user.email != "") {
                if (user.bloque != true) {
                  return Home(user: user);
                } else {
                  return const Material(
                      child: Center(
                          child: Text(
                    "Vous n'êtes pas authorisé.e à continuer.\nMerci de réessayer plus tard.",
                    textAlign: TextAlign.center,
                  )));
                }
              } else {
                return Welcome();
              }
            } else {
              return const Scaffold(body: Center(child: Loader()));
            }
          },
        ));
  }

  late auth.FirebaseAuth _auth;

  bool check = false;

  Future<auth.User?> _handleSignIn() async {
    auth.User? user = _auth.currentUser;
    check = true;
    return user;
  }

  Future<User?> getUser() async {
    auth.User? userTemp = await _handleSignIn();
    return User.read(userTemp != null ? userTemp.uid : "");
  }
}
