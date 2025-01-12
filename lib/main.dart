import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/phone_provider.dart';
import 'package:store_app/screens/add_phone_screen.dart';
import 'package:store_app/screens/edit_phone_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:store_app/screens/settings_screen.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          return ChangeNotifierProvider(
            create: (BuildContext context) => PhoneProvider(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'store app',
              theme: ThemeData(primarySwatch: Colors.blueGrey),
              initialRoute: '/',
              routes: {
                '/': (context) => const HomeScreen(),
                AddPhoneScreen.routeName: (context) => const AddPhoneScreen(),
                EditPhoneScreen.routeName: (context) => const EditPhoneScreen(),
                SettingsScreen.routeName: (context) => const SettingsScreen(),
              },
            ),
          );
        });
  }
}
