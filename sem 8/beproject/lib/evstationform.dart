import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding
import 'ev_station_list.dart'; // Import the EVStationListPage

class EVStationForm extends StatefulWidget {
  @override
  _EVStationFormState createState() => _EVStationFormState();
}

class _EVStationFormState extends State<EVStationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stationNameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _chargingRateController = TextEditingController();
  final TextEditingController _contactDetailsController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // New controller for the search bar

  List<String> _availableFor = [];
  bool _availableForCars = false;
  bool _availableForBikes = false;
  bool _availableForScooters = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick the image from the camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  // Function to search location and update latitude and longitude
  Future<void> _searchLocation() async {
    if (_locationController.text.isNotEmpty) {
      try {
        // Get the location from the search input
        List<Location> locations =
            await locationFromAddress(_locationController.text);

        // Get the first location's coordinates
        if (locations.isNotEmpty) {
          double latitude = locations.first.latitude;
          double longitude = locations.first.longitude;

          // Update the latitude and longitude fields
          setState(() {
            _latitudeController.text = latitude.toString();
            _longitudeController.text = longitude.toString();
          });
        }
      } catch (e) {
        print('Error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EV Station Form'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Navigate to EVStationListPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EVStationListPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Station Name
                TextFormField(
                  controller: _stationNameController,
                  decoration: InputDecoration(labelText: 'Station Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the station name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Search for Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                      labelText: 'Search Location (e.g., Mumbai, India)'),
                  onFieldSubmitted: (_) =>
                      _searchLocation(), // Call search on submit
                ),
                SizedBox(height: 16),

                // Latitude
                TextFormField(
                  controller: _latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Latitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the latitude';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Longitude
                TextFormField(
                  controller: _longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Longitude'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the longitude';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Availability for Vehicles
                Text('Available For:', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Checkbox(
                      value: _availableForCars,
                      onChanged: (value) {
                        setState(() {
                          _availableForCars = value!;
                          _toggleAvailableFor('Cars', value);
                        });
                      },
                    ),
                    Text('Cars'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _availableForBikes,
                      onChanged: (value) {
                        setState(() {
                          _availableForBikes = value!;
                          _toggleAvailableFor('Bikes', value);
                        });
                      },
                    ),
                    Text('Bikes'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _availableForScooters,
                      onChanged: (value) {
                        setState(() {
                          _availableForScooters = value!;
                          _toggleAvailableFor('Scooters', value);
                        });
                      },
                    ),
                    Text('Scooters'),
                  ],
                ),
                SizedBox(height: 16),

                // Charging Rate
                TextFormField(
                  controller: _chargingRateController,
                  decoration: InputDecoration(
                    labelText: 'Charging Rate (per hour or kWh)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the charging rate';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Contact Details
                TextFormField(
                  controller: _contactDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Contact Details (Phone or Email)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Image Picker for EV Station
                Text('Add Image:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 50),
                      ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt),
                        label: Text('Take Photo'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library),
                        label: Text('Select from Gallery'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Register Station Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerStation();
                      }
                    },
                    child: Text('Register Station'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAvailableFor(String vehicleType, bool isSelected) {
    if (isSelected) {
      _availableFor.add(vehicleType);
    } else {
      _availableFor.remove(vehicleType);
    }
  }

  // Register the station
  Future<void> _registerStation() async {
    final stationName = _stationNameController.text;
    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final address = _addressController.text;
    final chargingRate = _chargingRateController.text;
    final contactDetails = _contactDetailsController.text;

    try {
      // Check if the user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You must be logged in to register a station.'),
        ));
        return;
      }

      // Get the owner ID from the session
      final ownerId = user.uid;

      // Check if the station with the same name already exists
      QuerySnapshot existingStation = await FirebaseFirestore.instance
          .collection('stations')
          .where('stationName', isEqualTo: stationName)
          .get();

      if (existingStation.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Station with this name already exists.'),
        ));
        return; // Exit if station exists
      }

      // Upload image and get the URL
      String imageUrl = await _uploadImage();

      // Generate a new station ID (same as the document ID)
      DocumentReference newStationRef =
          FirebaseFirestore.instance.collection('stations').doc();

      // Save station data
      await newStationRef.set({
        'stationId': newStationRef.id,
        'ownerId': ownerId,
        'stationName': stationName,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'availableFor': _availableFor,
        'chargingRate': chargingRate,
        'contactDetails': contactDetails,
        'imageUrl': imageUrl,
      });

      // Clear the form
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Station registered successfully!'),
      ));
    } catch (error) {
      print('Error registering station: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to register station.'),
      ));
    }
  }

  Future<String> _uploadImage() async {
    if (_selectedImage == null) {
      return ''; // Return empty if no image selected
    }

    // Upload image to Firebase Storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('station_images/$fileName');
    await reference.putFile(_selectedImage!);
    return await reference.getDownloadURL();
  }

  void _clearForm() {
    _stationNameController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _addressController.clear();
    _chargingRateController.clear();
    _contactDetailsController.clear();
    _availableForCars = false;
    _availableForBikes = false;
    _availableForScooters = false;
    _availableFor.clear();
    _selectedImage = null;
    _locationController.clear(); // Clear the search location input
    setState(() {});
  }
}
