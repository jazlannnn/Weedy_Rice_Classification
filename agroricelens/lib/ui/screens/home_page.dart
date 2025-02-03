import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildInfoBox(
                title: 'What is AgroRiceLens?',
                imagePath: 'assets/images/AgroRiceLens-Logo.png',
                description: 'AgroRiceLens is a mobile app that uses AI to identify weedy rice through image classification. '
                    'It helps farmers make informed decisions, reduces reliance on chemicals, and supports sustainable farming. '
                    'This tool enhances rice production and ensures better agricultural practices for future generations.',
              ),
              _buildInfoBox(
                title: 'What is Weedy Rice?',
                imagePath: 'assets/images/weedy-rice.jpg',
                description: 'Weedy rice is a weed from the same genus as cultivated rice. '
                    'It absorbs nutrients efficiently, grows taller, and competes with rice for sunlight, '
                    'reducing yields by up to 80% in dense growth areas. Managing weedy rice is a major challenge for farmers.',

              ),
              _buildInfoBox(
                title: 'What is Cultivated Rice?',
                imagePath: 'assets/images/cultivated-rice.jpg',
                description: 'Cultivated rice (Oryza sativa) is a staple food for over half the world. '
                    'It grows up to 1.2 meters tall, with hollow stems and fibrous roots. Varieties differ in traits like size and yield, '
                    'making it adaptable and essential for global food security.',

              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String imagePath,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(imagePath),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

}
