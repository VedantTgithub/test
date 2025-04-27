import 'package:evofinal/ev_station_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'registration.dart'; // Import your RegistrationPage
import 'ev_station_info.dart'; // Import your EVStationInfo page
import 'vehicle_info_page.dart'; // Import your VehicleInfo page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Opacity(
            opacity: 0.5, // Adjust the opacity as needed
            child: Image.asset(
              'assets/images/baground.png', // Make sure to replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Centered login form
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Main color
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.blue),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.blue),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: Colors.blue), // Outline color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _loginUser();
                            }
                          },
                          child: Text('Login',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.blue)),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationPage()),
                            );
                          },
                          child: Text(
                            "Not registered? Go to Registration",
                            style: TextStyle(
                                color: Colors.blue), // Use your blue color
                          ),
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
    );
  }

  void _loginUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch the user's role and userId from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email) // Fetch user by email
          .limit(1) // Limit to one document
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (userDoc.exists) {
        String role = userDoc['role']; // Assuming you have a 'role' field
        String userId = userDoc['userId']; // Get ownerId from the user document

        // Navigate based on user role
        if (role == 'EV Owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VehicleInfo(userId: userId), // Pass userId to VehicleInfo
            ),
          );
        } else if (role == 'Station Owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EVStationListPage(), // Navigate to EVStationListPage
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Unknown role: $role'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User document does not exist.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: $e'),
      ));
    }
  }
}
