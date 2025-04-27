import 'package:evofinal/evstationform.dart';
import 'package:evofinal/stationinfo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ev_station_info.dart'; // Import the EVStationForm page
import 'package:firebase_auth/firebase_auth.dart';

class EVStationListPage extends StatelessWidget {
  final String currentUserId =
      FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered EV Stations'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
              Navigator.pushReplacementNamed(
                  context, '/login'); // Redirect to LoginPage
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('User not found.'));
          }

          var userDoc = userSnapshot.data!.docs.first;
          var ownerId = userDoc['userId'];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stations')
                .where('ownerId', isEqualTo: ownerId)
                .snapshots(),
            builder: (context, stationSnapshot) {
              if (stationSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!stationSnapshot.hasData ||
                  stationSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No stations registered.'));
              }

              return ListView.builder(
                itemCount: stationSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var stationData = stationSnapshot.data!.docs[index].data()
                      as Map<String, dynamic>;

                  String stationName =
                      stationData['stationName'] ?? 'Unknown Station';
                  String chargingRate =
                      stationData['chargingRate']?.toString() ?? 'N/A';
                  String imagePath = stationData['imageUrl'] ?? '';

                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      elevation: 6,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StationInfo(
                                  stationId:
                                      stationSnapshot.data!.docs[index].id),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16.0)),
                                image: DecorationImage(
                                  image: NetworkImage(imagePath.isNotEmpty
                                      ? imagePath
                                      : 'https://via.placeholder.com/150'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stationName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Charging Rate: ₹$chargingRate',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // Floating action button for adding a new station
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EVStationForm(), // Navigate to EVStationForm
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Station',
      ),
    );
  }
}
