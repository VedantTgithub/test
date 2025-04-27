import 'package:evofinal/evstationreview.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ev_station_info.dart';

class EVStationListAllPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All EV Stations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('stations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stations found.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Display two cards per row, like Airbnb
              childAspectRatio: 0.8, // Adjust the card height and width ratio
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var stationData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Safely retrieve data with null checks
              String stationName =
                  stationData['stationName'] ?? 'Unknown Station';
              String chargingRate =
                  stationData['chargingRate']?.toString() ?? 'N/A';
              String imagePath =
                  stationData['imagePath'] ?? ''; // Default to empty string

              return GestureDetector(
                onTap: () {
                  // Navigate to the detailed station info page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EVStationReview(
                          stationId: snapshot.data!.docs[index].id),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image for the EV station
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(imagePath.isNotEmpty
                                ? imagePath
                                : 'https://via.placeholder.com/150'), // Fallback image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Station Name
                            Text(
                              stationName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            // Charging Rate
                            Text(
                              '₹$chargingRate / hour',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
