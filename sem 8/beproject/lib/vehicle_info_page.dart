import 'package:evofinal/evstationbook.dart';
import 'package:evofinal/evstationlistall.dart';
import 'package:evofinal/vehicleform.dart'; // Import the AddVehicleForm
import 'package:evofinal/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart'; // Import your MapScreen here
import 'plan_trip_screen.dart'; // Import your PlanTripScreen here

class VehicleInfo extends StatefulWidget {
  final String userId; // The ID of the user whose vehicles we want to display

  VehicleInfo({required this.userId}); // Constructor to accept user ID

  @override
  _VehicleInfoState createState() => _VehicleInfoState();
}

class _VehicleInfoState extends State<VehicleInfo> {
  int _selectedIndex = 0; // Default to the profile page

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginPage()), // Redirect to LoginPage
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Handle error if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Owner Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Black icon theme
      ),
      body: _selectedIndex == 0 ? _buildVehicleList() : _buildPlaceholder(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Colors.black),
            label: 'Find Charger',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trip_origin, color: Colors.black),
            label: 'Plan Trip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews, color: Colors.black),
            label: 'Review Station',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online, color: Colors.black),
            label: 'Book Station', // New item for booking EV stations
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black, // Black color for selected item
        unselectedItemColor: Colors.black, // Black color for unselected items
      ),
      floatingActionButton: _selectedIndex ==
              0 // Show button only on Vehicle List page
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to AddVehicleForm and pass the current user ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVehicleForm(userId: widget.userId),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null, // Hide button on other pages
    );
  }

  Widget _buildVehicleList() {
    return StreamBuilder<QuerySnapshot>(
      // Query for vehicles registered by the user
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: widget.userId) // Filter by owner ID
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
                  color: Colors.greenAccent
                      .withOpacity(0.1), // Light green background
                  border: Border.all(color: Colors.black), // Black border
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(
                            255, 40, 116, 43), // Green text for the title
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
    );
  }

  Widget _buildPlaceholder() {
    switch (_selectedIndex) {
      case 1:
        return MapScreen(); // Your MapScreen widget
      case 2:
        return PlanTripScreen();
      case 3:
        return EVStationListAllPage();
      case 4:
        return EVStationBook(); // Your PlanTripScreen widget
      default:
        return Container();
    }
  }
}
