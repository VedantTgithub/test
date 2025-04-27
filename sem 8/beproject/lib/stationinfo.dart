import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationInfo extends StatelessWidget {
  final String stationId;

  StationInfo({required this.stationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Station Info'),
      ),
      body: Column(
        children: [
          // Fetching Station Details
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('stations') // Fetch from the stations collection
                .doc(stationId) // Match the stationId
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
                    Image.network(
                      stationData['imagePath'] ??
                          'https://via.placeholder.com/150',
                    ),

                    // Station Details
                    _buildStationDetails(stationData),

                    // Charging Rates
                    _buildChargingRates(stationData),

                    // Slots Section
                    _buildSlotSection(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Station Details Widget
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
          Text(
            stationData['stationName'] ?? 'Unknown Station',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Available for: ${stationData['availableFor'] ?? 'N/A'}'),
          SizedBox(height: 8),
          Text('Contact: ${stationData['contactDetails'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  // Charging Rates Widget
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
        'Charging Rate: ₹${stationData['chargingRate'] ?? 'N/A'} per hour',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Slots Section
  Widget _buildSlotSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('book') // Root collection
          .doc('8pOYfnRNDkWxwc1IKC3L') // Default document ID
          .collection('stations') // Subcollection for stations
          .doc(stationId) // Match the station ID
          .collection('slots') // Subcollection for slots
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No slots booked.'));
        }

        return Column(
          children: snapshot.data!.docs.map((slotDoc) {
            var slotData = slotDoc.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(slotData['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Container();
                }

                var userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                return _buildSlotCard(slotData, userData, slotDoc.id);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Slot Card
  Widget _buildSlotCard(Map<String, dynamic> slotData,
      Map<String, dynamic> userData, String slotId) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slot: ${slotData['from']} - ${slotData['to']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('User: ${userData['name'] ?? 'Unknown'}'),
            Text('Email: ${userData['email'] ?? 'Unknown'}'),
            Text('Vehicle: ${userData['vehicle'] ?? 'Unknown'}'),
            Text('Status: ${slotData['status']}'),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _updateSlotStatus(slotId, 'approved'),
                  child: Text('Approve'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateSlotStatus(slotId, 'declined'),
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Update Slot Status
  void _updateSlotStatus(String slotId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('book') // Root collection
          .doc('8pOYfnRNDkWxwc1IKC3L') // Default document ID
          .collection('stations') // Subcollection for stations
          .doc(stationId) // Match the station ID
          .collection('slots') // Subcollection for slots
          .doc(slotId) // Update the slot by ID
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating slot status: $e');
    }
  }
}
