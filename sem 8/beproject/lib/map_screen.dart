import 'dart:convert'; // Import for jsonEncode and jsonDecode
import 'dart:ui';
import 'package:evofinal/vehicle_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:location/location.dart' as loc; // Import location
import 'package:http/http.dart' as http; // Import HTTP package
import 'station_owner_home.dart';
import 'profile.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final List<LatLng> _routePoints = []; // Store route points
  loc.LocationData? _currentLocation; // Store current location
  String? _selectedStationName; // Store selected station name
  List<String>? _availableFor; // Store availableFor array
  LatLng? _searchDestination; // Store search destination
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search input
  bool _isPolylineVisible = false; // Control polyline visibility

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation(); // Fetch current location on startup
    _fetchStations(); // Fetch the registered stations
  }

  void _fetchCurrentLocation() async {
    loc.Location location = loc.Location();

    try {
      _currentLocation = await location.getLocation(); // Get current location

      if (_currentLocation != null) {
        // Add marker for the current location
        setState(() {
          _markers.add(
            Marker(
              point: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              builder: (context) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.5), // Blue marker
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ),
          );

          // Move the map to the user's current location
          _mapController.move(
            LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            15.0,
          );
        });
      }
    } catch (e) {
      print("Could not get location: $e");
    }
  }

  void _fetchStations() {
    print("Fetching stations from Firestore...");

    FirebaseFirestore.instance
        .collection('stations') // Ensure this matches your collection name
        .snapshots()
        .listen((snapshot) {
      // Clear existing markers except for the current location
      _markers.removeWhere((marker) =>
          marker.point ==
          LatLng(
            _currentLocation?.latitude ?? 0.0,
            _currentLocation?.longitude ?? 0.0,
          ));

      // Iterate through the documents and create markers
      for (var doc in snapshot.docs) {
        var stationData = doc.data() as Map<String, dynamic>;

        // Extract latitude and longitude
        double latitude = stationData['latitude'] ?? 0.0;
        double longitude = stationData['longitude'] ?? 0.0;

        // Ensure the latitude and longitude are valid
        if (latitude != 0.0 && longitude != 0.0) {
          // Add a marker for the station
          _markers.add(
            Marker(
              point: LatLng(latitude, longitude),
              builder: (context) => GestureDetector(
                onTap: () {
                  // Show station info
                  setState(() {
                    _selectedStationName = stationData['stationName'];
                    _availableFor =
                        List<String>.from(stationData['availableFor']);
                    _isPolylineVisible = false; // Reset polyline visibility
                  });

                  // Show details in a dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(_selectedStationName ?? 'Station Info'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Available for:'),
                            if (_availableFor != null)
                              for (var service in _availableFor!)
                                Text('- $service'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            ),
          );
        } else {
          print('Invalid station data: Latitude or Longitude missing.');
        }
      }

      setState(() {}); // Update the UI after fetching markers
    });
  }

  Future<void> _fetchRouteToStation(LatLng destination) async {
    if (_currentLocation == null) {
      print("Current location is not available.");
      return;
    }

    final String url =
        'http://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${destination.longitude},${destination.latitude}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];

        // Clear previous route points
        _routePoints.clear();

        // Add new route points
        for (var coord in coordinates) {
          _routePoints.add(LatLng(coord[1], coord[0]));
        }

        setState(() {
          // Fit the map to show the route
          LatLngBounds bounds = LatLngBounds(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            destination,
          );

          _mapController.fitBounds(
            bounds,
            options: FitBoundsOptions(padding: EdgeInsets.all(30)),
          );
        });

        print('Route fetched successfully.');
      } else {
        print('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  //  Perform geocoding
  Future<void> _searchLocation() async {
    final String query = _searchController.text.trim(); // Trim whitespace

    if (query.isNotEmpty) {
      try {
        // Use the geocoding package to get coordinates from the address
        List<Location> locations = await locationFromAddress(query);

        if (locations.isNotEmpty) {
          final coordinates =
              locations.first; // Get the first result's coordinates

          // Clear previous search destination marker
          if (_searchDestination != null) {
            _markers
                .removeWhere((marker) => marker.point == _searchDestination);
          }

          setState(() {
            _searchDestination =
                LatLng(coordinates.latitude, coordinates.longitude);
            _markers.add(Marker(
              point: _searchDestination!,
              builder: (context) => Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ));
          });

          // Move the map to the searched destination
          _mapController.move(_searchDestination!, 15.0);
        } else {
          print('No results found for the query.');
        }
      } catch (e) {
        print('Error fetching geocode: $e');
      }
    } else {
      print('Search query is empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Station Map'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(37.7749, -122.4194),
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(25.0), // Increased corner radius
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 15.0, sigmaY: 15.0), // Blur effect
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.4), // Transparent white background
                      borderRadius: BorderRadius.circular(
                          25.0), // Increased corner radius
                      border: Border.all(
                          color: Colors.grey.shade400), // Optional border color
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search locations...',
                                border:
                                    InputBorder.none, // Remove default border
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search,
                              color: const Color.fromARGB(
                                  255, 41, 41, 41)), // Search icon
                          onPressed: _searchLocation,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              15.0,
            );
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
