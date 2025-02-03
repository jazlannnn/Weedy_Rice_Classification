import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for SystemNavigator
import 'package:agroricelens/ui/root_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _Onboarding_ScreenState();
}

class _Onboarding_ScreenState extends State<OnboardingScreen> {
  final String imagePath = 'assets/images/AgroRiceLens_Logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff), // Changed background color
      body: Container(
        width: double.infinity, // Ensures the container takes the full width
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Centers items horizontally
          children: [
            SizedBox(
              height: 300, // Adjusted height to 300
              child: Image.asset(imagePath), // Only the image
            ),
            const SizedBox(height: 10), // Reduced spacing between image and buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RootPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff008748), // Updated green button color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Start',
                style: TextStyle(color: Color(0xff000000)), // Set button text color to black
              ),
            ),
            const SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop(); // Exits the app
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffff3333), // Updated red button color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(color: Color(0xff000000)), // Set button text color to black
              ),
            ),
            const SizedBox(height: 20), // Add margin at the bottom for spacing
          ],
        ),
      ),
    );
  }
}
