import 'package:evofinal/evstationform.dart';
import 'package:evofinal/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import your login page here // Import your EVStationForm page here

class EVStationInfo extends StatelessWidget {
  final String stationId; // The ID of the station to fetch

  EVStationInfo({required this.stationId}); // Constructor to accept station ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Station Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Add your logout logic here
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('stations')
            .doc(stationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Station not found.'));
          }

          var stationData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Image of EV station
                Image.network(stationData['imagePath'] ??
                    'https://via.placeholder.com/150'), // Use a placeholder if no image is available

                // First Textbox
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stationData['stationName'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Available for:', style: TextStyle(fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (stationData['availableFor'].contains('Bikes'))
                            Column(
                              children: [
                                Icon(Icons.motorcycle,
                                    size: 30), // Icon for bikes
                                Text('Bikes'),
                              ],
                            ),
                          SizedBox(width: 20),
                          if (stationData['availableFor'].contains('Scooters'))
                            Column(
                              children: [
                                Icon(Icons.electric_scooter,
                                    size: 30), // Icon for scooters
                                Text('Scooters'),
                              ],
                            ),
                          SizedBox(width: 20),
                          if (stationData['availableFor'].contains('Cars'))
                            Column(
                              children: [
                                Icon(Icons.directions_car,
                                    size: 30), // Icon for cars
                                Text('Cars'),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Rating:', style: TextStyle(fontSize: 16)),
                      Row(
                        children: List.generate(
                          4,
                          (index) => Icon(Icons.star, color: Colors.amber),
                        )..add(Icon(Icons.star_border)),
                      ),
                      SizedBox(height: 8),
                      // Display contact details directly on this page
                      Text(
                          'Contact Number: ${stationData['contactDetails'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

                // Second Textbox for Charging Rates
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  child: Text(
                      'Charging Rates: ₹${stationData['chargingRate'] ?? 'N/A'} per hour',
                      style: TextStyle(fontSize: 16)),
                ),

                // Third Textbox for Charging History
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('History of Users Who Visited:',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      // Hardcoded reviews (you can replace this with dynamic data)
                      Text('1. User A: ⭐⭐⭐⭐', style: TextStyle(fontSize: 14)),
                      Text('2. User B: ⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 14)),
                      Text('3. User C: ⭐⭐⭐', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Switch(
              value: false,
              onChanged: (value) {
                // Handle switch changes here
              },
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.white), // Route plan button
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, color: Colors.white), // Explore button
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white), // Profile button
            label: '',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation bar taps here
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EVStationForm()), // Navigate to EVStationForm
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Station',
      ),
    );
  }
}
