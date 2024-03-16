import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:Islah.AI/models/qibla_page.dart';
import 'package:Islah.AI/views/media_selection.dart';
import 'package:Islah.AI/views/namaz_timings.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(123, 35, 196, 245),
        minimumSize: Size(size.width * 0.85, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.15,
            ),
            Container(
              alignment: Alignment.center,
              width: size.width * 0.7,
              height: size.width * 0.7,
              child: Lottie.asset('assets/logo.json'),
            ),
            const SizedBox(height: 40),
            const Text(
              '',
              style: TextStyle(
                  fontSize: 38.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2),
            ),
            SizedBox(
              width: size.width * 0.7,
              child: Text(
                'Enhance your prayer experience with Islah.AI.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6)),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              style: raisedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VideoSelectionWidget()),
                );
              },
              child: const Text(
                "Posture Analysis",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            OutlinedButton(
              style: raisedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaPage()),
                );
              },
              child: const Text(
                "Qibla Compass",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            OutlinedButton(
              style: raisedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NamazReminder()),
                );
              },
              child: const Text(
                "Namaz Reminder",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}
