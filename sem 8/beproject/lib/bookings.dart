import 'package:evofinal/bookslotpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Main Bookings Page
class Bookings extends StatelessWidget {
  final String stationId; // The ID of the station to fetch

  Bookings({required this.stationId}); // Constructor to accept station ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Station Booking'),
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
                    'https://via.placeholder.com/150'),

                // First Textbox
                _buildStationDetails(stationData),

                // Second Textbox for Charging Rates
                _buildChargingRates(stationData),

                // Display Reviews
                _buildReviewSection(stationId),

                // Button to book the station
                SizedBox(height: 20), // Add spacing before the button
                ElevatedButton(
                  onPressed: () {
                    // Action to book the station (currently no route)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingSlotPage(stationId: stationId),
                      ),
                    );
                  },
                  child: Text('Book Station'),
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
    );
  }

  // Function to build station details
  Widget _buildStationDetails(Map<String, dynamic> stationData) {
    return Container(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Available for:', style: TextStyle(fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (stationData['availableFor'].contains('Bikes'))
                Column(
                  children: [
                    Icon(Icons.motorcycle, size: 30),
                    Text('Bikes'),
                  ],
                ),
              SizedBox(width: 20),
              if (stationData['availableFor'].contains('Scooters'))
                Column(
                  children: [
                    Icon(Icons.electric_scooter, size: 30),
                    Text('Scooters'),
                  ],
                ),
              SizedBox(width: 20),
              if (stationData['availableFor'].contains('Cars'))
                Column(
                  children: [
                    Icon(Icons.directions_car, size: 30),
                    Text('Cars'),
                  ],
                ),
            ],
          ),
          SizedBox(height: 8),
          Text('Contact Number: ${stationData['contactDetails'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Function to build charging rates textbox
  Widget _buildChargingRates(Map<String, dynamic> stationData) {
    return Container(
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
    );
  }

  // Function to build review section
  Widget _buildReviewSection(String stationId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Reviews', style: TextStyle(fontSize: 20)),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .where('stationId', isEqualTo: stationId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print("No reviews found for station ID: $stationId");
                return Text('No reviews yet.');
              }

              // Log the fetched reviews for debugging
              snapshot.data!.docs.forEach((doc) {
                print("Fetched review: ${doc.data()}");
              });

              return ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  var reviewData = doc.data() as Map<String, dynamic>;
                  return _buildReviewCard(reviewData);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Function to build each review card
  Widget _buildReviewCard(Map<String, dynamic> reviewData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(reviewData['evOwnerId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(); // Handle case where user data is not found
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Card(
          margin: EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying the user's name
                Text(
                  userData['name'] ?? 'Unknown User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                // Rating stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < reviewData['rating']
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                SizedBox(height: 5),
                // Review text
                Text(
                  reviewData['reviewText'] ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                // Review time
                Text(
                  'On: ${reviewData['reviewTime'].toDate().toString()}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
