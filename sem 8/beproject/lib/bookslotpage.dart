import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingSlotPage extends StatelessWidget {
  final String stationId;

  BookingSlotPage({required this.stationId});

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to get the current user ID
  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in.');
    }
  }

  // Function to book a slot
  Future<void> bookSlot(BuildContext context) async {
    if (fromController.text.isEmpty || toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both From and To times.')),
      );
      return;
    }

    try {
      String fromTime = fromController.text;
      String toTime = toController.text;
      String userId = getCurrentUserId(); // Fetch the current user ID

      // Add a new slot document under the appropriate station
      await _firestore
          .collection('book') // Root collection
          .doc('8pOYfnRNDkWxwc1IKC3L') // Default document ID
          .collection('stations') // Subcollection for stations
          .doc(stationId) // Match the station ID
          .collection('slots') // Subcollection for slots
          .add({
        'userId': userId,
        'stationId': stationId,
        'from': fromTime,
        'to': toTime,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot booked successfully!')),
      );

      // Clear the text fields after booking
      fromController.clear();
      toController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book slot: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Time Slot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input for 'From' time
            TextField(
              controller: fromController,
              decoration: InputDecoration(
                labelText: 'From',
                hintText: 'Select start time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTime != null) {
                  fromController.text = selectedTime.format(context);
                }
              },
            ),

            SizedBox(height: 16),

            // Input for 'To' time
            TextField(
              controller: toController,
              decoration: InputDecoration(
                labelText: 'To',
                hintText: 'Select end time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTime != null) {
                  toController.text = selectedTime.format(context);
                }
              },
            ),

            SizedBox(height: 20),

            // Book slot button
            ElevatedButton(
              onPressed: () => bookSlot(context),
              child: Text('Book Slot'),
            ),

            SizedBox(height: 20),

            // Already booked slots section
            Text('Already Booked Slots:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('book')
                    .doc('8pOYfnRNDkWxwc1IKC3L') // Default document ID
                    .collection('stations')
                    .doc(stationId)
                    .collection('slots')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No slots booked yet.'));
                  }

                  final bookedSlots = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: bookedSlots.length,
                    itemBuilder: (context, index) {
                      final slot =
                          bookedSlots[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(Icons.event_available),
                        title:
                            Text('From: ${slot['from']} - To: ${slot['to']}'),
                        subtitle: Text('Status: ${slot['status']}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
