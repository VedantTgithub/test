import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scooter Name Dropdown
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: 'My 450',
                    items: <String>['My 450', 'My 350', 'My 300']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 20)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Handle change
                    },
                  ),
                  SizedBox(width: 48), // Placeholder for notification icon
                ],
              ),
            ),

            // First Textbox
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('31 km',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('2h 09 min for full charge',
                          style: TextStyle(fontSize: 20)),
                      SizedBox(height: 8),
                      Text('Charging now',
                          style: TextStyle(fontSize: 20, color: Colors.green)),
                    ],
                  ),
                ),
                // Image on top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/ather-450.png', // Adjust the path if necessary
                    width: 100, // Adjust the size as needed
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            // Use Maps
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Use Maps',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),

            // Action Buttons
            Container(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionBox(icon: Icons.electric_car, label: 'Find Charger'),
                  ActionBox(icon: Icons.location_on, label: 'Locate Scooter'),
                  ActionBox(icon: Icons.search, label: 'Search Place'),
                  ActionBox(
                      icon: Icons.electric_scooter, label: 'Find Charger'),
                ],
              ),
            ),

            // Recent Rides
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Your Recent Ride',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),

            // Ride Details Textboxes
            Container(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RideDetailBox(
                      efficiency: '45 km/h',
                      duration: '30 min',
                      topSpeed: '60 km/h'),
                  RideDetailBox(
                      efficiency: '50 km/h',
                      duration: '25 min',
                      topSpeed: '70 km/h'),
                  RideDetailBox(
                      efficiency: '40 km/h',
                      duration: '35 min',
                      topSpeed: '65 km/h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionBox extends StatelessWidget {
  final IconData icon;
  final String label;

  ActionBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class RideDetailBox extends StatelessWidget {
  final String efficiency;
  final String duration;
  final String topSpeed;

  RideDetailBox(
      {required this.efficiency,
      required this.duration,
      required this.topSpeed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: 250, // Set fixed width for scrolling
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Efficiency: $efficiency', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Duration: $duration', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Text('Top Speed: $topSpeed', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
