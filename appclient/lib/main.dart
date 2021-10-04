import 'package:appclient/SplashScreen.dart';
import 'package:flutter/material.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'sciot-app',
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
