import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleInfo extends StatelessWidget {
  final String userId; // The ID of the user whose vehicles we want to display

  VehicleInfo({required this.userId}); // Constructor to accept user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Info'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query for vehicles registered by the user
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('ownerId', isEqualTo: userId) // Filter by owner ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No vehicles found.'));
          }

          // List of vehicle documents
          var vehicles = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: vehicles.map((vehicleDoc) {
                var vehicleData = vehicleDoc.data() as Map<String, dynamic>;

                return Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Model: ${vehicleData['vehicleModel'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Type: ${vehicleData['vehicleType'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mileage: ${vehicleData['mileage'] ?? 'N/A'} km/l',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Registration Number: ${vehicleData['registrationNumber'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
