import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';
class EVStationOwnerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Station Owner Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image of EV station
            Image.asset('assets/images/evstation.jpg'),

            // First Textbox
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  // First box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Vijay CHS EVCS',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Available for:', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.electric_scooter), // Scooter icon
                          Text('Scooters'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.directions_car), // Car icon
                          Text('Cars'),
                        ],
                      ),
                    ],
                  ),
                  // Ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_border), // One empty star for 4-star rating
                    ],
                  ),
                  // Charging availability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.bolt), // Charging icon
                      Text('Available Charging'),
                    ],
                  ),
                  // Contact Details
                  TextButton(
                    onPressed: () {
                      // Navigate to Contact Details Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactDetailsPage()),
                      );
                    },
                    child: Text('Contact Details'),
                  ),
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
              child:
                  Text('Charging Rates in Rs', style: TextStyle(fontSize: 16)),
            ),

            // Third Textbox for Charging History
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text('History of Users Who Visited',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),

      // Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Switch(
              value: false, // Handle state management for the switch
              onChanged: (value) {
                // Navigate to EV Owner Home Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EVOwnerHomePage()),
                );
              },
            ),
            label: 'Switch to EV Owner Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info), // Icon for the second item
            label: 'Info',
          ),
          // Map button
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // Map icon
            label: 'Map',
          ),
        ],
        currentIndex: 0, // Set the current index
        onTap: (index) {
          // Handle item tap
          if (index == 1) {
            // Navigate to Info Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InfoPage()),
            );
          } else if (index == 2) {
            // Navigate to Map Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()), // Navigate to the Map screen
            );
          }
        },
      ),
    );
  }
}

// Placeholder for Contact Details Page
class ContactDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details'),
      ),
      body: Center(
        child: Text('Contact details will be shown here.'),
      ),
    );
  }
}

// Placeholder for EV Owner Home Page
class EVOwnerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Owner Home'),
      ),
      body: Center(
        child: Text('Welcome to the EV Owner Home Page!'),
      ),
    );
  }
}

// Placeholder for Info Page
class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Information'),
      ),
      body: Center(
        child: Text('This is the Info Page.'),
      ),
    );
  }
}


