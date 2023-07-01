import 'package:flutter/material.dart';
import 'package:webloi/pages/home.dart';

void main() { 
  Paint.enableDithering = true;
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: Scaffold(body: Home()));
  }
}
