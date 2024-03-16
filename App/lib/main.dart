import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Islah.AI/models/push_up_model.dart';
import 'package:Islah.AI/views/splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PushUpCounter(),
      child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Islah.AI',
          home: SplashScreen()),
    );
  }
}
