import 'package:flutter/material.dart';
import 'package:meal_plan_app/src/imports/imports_pages.dart';

void main() => runApp(const NutriAIApp());

class NutriAIApp extends StatelessWidget {
  const NutriAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Nutri AI',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
          '/forms': (context) => const FormPage(),
        });
  }
}
