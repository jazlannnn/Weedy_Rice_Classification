import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // Sample data with LatLng for Google Maps
  final List<Map<String, dynamic>> paddyFields = [
    {
      'name': 'Bukit Chabang',
      'location': 'Perlis, Malaysia',
      'description': 'Paddy Field located in Perlis',
      'address': 'J775+9H, 02100 Padang Besar, Perlis',
      'latLng': LatLng(6.613752907276439, 100.25921047671278),
      'locationImage': 'assets/images/perlis.jpg', // Dummy Image URL
      'operationTime': {
        'Monday': 'Open 24 hours',
        'Tuesday': 'Open 24 hours',
        'Wednesday': 'Open 24 hours',
        'Thursday': 'Open 24 hours',
        'Friday': 'Open 24 hours',
        'Saturday': 'Open 24 hours',
        'Sunday': 'Open 24 hours',
      },
    },
    {
      'name': 'Kota Sarang Semut',
      'location': 'Kedah, Malaysia',
      'description': 'Paddy Field located in Kedah.',
      'address': 'WCG7+W4, Simpang Tiga Sungai Daun, 06800 Kota Sarang Semut, Kedah',
      'latLng': LatLng(5.959516519129619, 100.4231433084499),
      'locationImage': 'assets/images/kedah.jpg', // Dummy Image URL
      'operationTime': {
        'Monday': 'Open 24 hours',
        'Tuesday': 'Open 24 hours',
        'Wednesday': 'Open 24 hours',
        'Thursday': 'Open 24 hours',
        'Friday': 'Open 24 hours',
        'Saturday': 'Open 24 hours',
        'Sunday': 'Open 24 hours',
      },
    },
    {
      'name': 'Kampung Chui Chak ',
      'location': 'Perak, Malaysia',
      'description': 'Paddy Field located in Perak.',
      'address': '36700 Langkap, Perak',
      'latLng': LatLng(4.058802914155152, 101.16319501161465),
      'locationImage': 'assets/images/perak.jpg', // Dummy Image URL
      'operationTime': {
        'Monday': '9:00 AM - 6:00 PM',
        'Tuesday': '9:00 AM - 6:00 PM',
        'Wednesday': '9:00 AM - 6:00 PM',
        'Thursday': '9:00 AM - 6:00 PM',
        'Friday': '9:00 AM - 6:00 PM',
        'Saturday': '10:00 AM - 4:00 PM',
        'Sunday': 'Closed',
      },
    },
  ];

  void _showPaddyFieldDetails(BuildContext context, Map<String, dynamic> paddyField) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                paddyField['name']!,
                style: const TextStyle(
                  fontSize: 20,  // Adjust size if necessary
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: ${paddyField['location']}'),
              const SizedBox(height: 10),
              Text('Description: ${paddyField['description']}'),
              const SizedBox(height: 10),
              Text('Address: ${paddyField['address']}'),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: paddyField['latLng'] as LatLng,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(paddyField['name']),
                      position: paddyField['latLng'] as LatLng,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Show Location Image
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('${paddyField['name']} Paddy Field Photos'),
                            content: paddyField['locationImage'] != null
                                ? Image.asset(
                              paddyField['locationImage'], // Use Image.asset for local images
                              fit: BoxFit.cover,
                            )
                                : const Text('No image available'),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Photos',
                      style: TextStyle(
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Show Operation Time
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('${paddyField['name']} Operation Hours'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: (paddyField['operationTime'] as Map<String, String>).entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text('${entry.key}: ${entry.value}'),
                                );
                              }).toList(),
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Hours',
                      style: TextStyle(
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: paddyFields.length,
        itemBuilder: (context, index) {
          final paddyField = paddyFields[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () => _showPaddyFieldDetails(context, paddyField),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paddyField['name']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Darker color for better visibility
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      paddyField['location']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      paddyField['description']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
