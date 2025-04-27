import 'package:evofinal/vehicle_info_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For image storage
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For handling file system
import 'dart:ui'; // For ImageFilter

class AddVehicleForm extends StatefulWidget {
  final String userId; // Add the userId parameter

  AddVehicleForm({required this.userId}); // Constructor

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();

  String _vehicleType = 'Car'; // Default vehicle type
  String _vehicleModel = '';
  String _registrationNumber = '';
  String _mileage = '';
  File? _vehicleImage; // Image file
  bool _isLoading = false; // Loading state

  final ImagePicker _picker = ImagePicker();

  // Function to select an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the URL
  Future<String?> _uploadImage(String vehicleId) async {
    if (_vehicleImage == null) return null;

    try {
      // Create a reference to the Firebase Storage bucket
      final storageRef =
          FirebaseStorage.instance.ref().child('vehicle_images/$vehicleId.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_vehicleImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the URL of the uploaded image
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload image: $e'),
      ));
      return null;
    }
  }

  Future<void> _saveVehicleData() async {
    // Get the current user's ID (ownerId) from Firebase Authentication
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You must be logged in to add a vehicle.'),
      ));
      return;
    }

    String ownerId = user.uid;

    // Generate a unique vehicle ID (same as Firestore document ID)
    DocumentReference vehicleDocRef =
        FirebaseFirestore.instance.collection('vehicles').doc();
    String vehicleId = vehicleDocRef.id;

    // Upload the vehicle image to Firebase Storage
    String? imageUrl = await _uploadImage(vehicleId);

    // Build the vehicle data JSON object
    Map<String, dynamic> vehicleData = {
      "vehicleId": vehicleId,
      "ownerId": ownerId,
      "vehicleType": _vehicleType.toLowerCase(), // Car, bike, or scooter
      "vehicleModel": _vehicleModel,
      "registrationNumber": _registrationNumber,
      "mileage": double.tryParse(_mileage) ?? 0.0,
      "imageUrl": imageUrl, // Add the image URL to the Firestore document
      "createdAt": DateTime.now().toIso8601String(),
    };

    // Save the data to Firestore
    try {
      setState(() {
        _isLoading = true;
      });
      await vehicleDocRef.set(vehicleData);

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Vehicle added successfully!'),
      ));

      // Navigate to VehicleInfo page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => VehicleInfo(
                  userId: ownerId, // Pass the ownerId here
                )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add vehicle: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
        _formKey.currentState?.reset();
        _vehicleType = 'Car'; // Reset default vehicle type
        _vehicleImage = null; // Clear the image
        _vehicleModel = '';
        _registrationNumber = '';
        _mileage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // Dark green app bar
      ),
      body: Stack(
        children: [
          // Greyish green background with blur effect
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: const Color.fromARGB(223, 255, 255, 255)
                    .withOpacity(0.3), // Greyish green background
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Glass-like effect
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                      Border.all(color: Colors.green, width: 2), // Green border
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dropdown for vehicle type
                      DropdownButtonFormField<String>(
                        value: _vehicleType,
                        items: ['Car', 'Bike', 'Scooter']
                            .map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _vehicleType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a vehicle type.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Text field for vehicle model
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Vehicle Model',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        onChanged: (value) {
                          _vehicleModel = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the vehicle model.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Text field for registration number
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Registration Number',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        onChanged: (value) {
                          _registrationNumber = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the registration number.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Text field for mileage
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mileage (in KW/h)',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        onChanged: (value) {
                          _mileage = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the mileage.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Image selection button
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Select Vehicle Image'),
                      ),

                      // Display selected image
                      SizedBox(height: 16.0),
                      _vehicleImage != null
                          ? Image.file(
                              _vehicleImage!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : SizedBox(
                              height: 150,
                              child: Center(
                                child: Text('No image selected.'),
                              ),
                            ),

                      // Submit button
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveVehicleData,
                        child: _isLoading
                            ? CircularProgressIndicator() // Show loading indicator
                            : Text('Add Vehicle'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
