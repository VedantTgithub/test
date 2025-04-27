// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
// import 'dart:convert'; // For utf8
// import 'package:crypto/crypto.dart'; // For sha256

// class RegistrationPage extends StatefulWidget {
//   @override
//   _RegistrationPageState createState() => _RegistrationPageState();
// }

// class _RegistrationPageState extends State<RegistrationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   String? _selectedRole;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Registration"),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Name'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your name';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 return null;
//               },
//             ),
//             TextFormField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 return null;
//               },
//             ),
//             DropdownButtonFormField<String>(
//               value: _selectedRole,
//               hint: Text('Select Role'),
//               items: ['EV Owner', 'Station Owner'].map((String role) {
//                 return DropdownMenuItem<String>(
//                   value: role,
//                   child: Text(role),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedRole = value;
//                 });
//               },
//               validator: (value) {
//                 if (value == null) {
//                   return 'Please select a role';
//                 }
//                 return null;
//               },
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   _registerUser();
//                 }
//               },
//               child: Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _registerUser() async {
//     final name = _nameController.text;
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     try {
//       // Authenticate the user with Firebase Authentication
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Hash the password with sha256 for Firestore storage (optional)
//       var bytes = utf8.encode(password);
//       var hashedPassword = sha256.convert(bytes).toString();

//       String userId = userCredential.user!.uid;

//       // Reference to the Firestore user collection
//       CollectionReference usersRef =
//           FirebaseFirestore.instance.collection('users');

//       // Store the user in Firestore using the userId as the document ID
//       await usersRef.doc(userId).set({
//         'userId': userId, // Same as Firebase Authentication user UID
//         'name': name,
//         'email': email,
//         'role': _selectedRole, // 'ev_owner' or 'station_owner'
//         'registeredAt': FieldValue.serverTimestamp(),
//         // Store hashedPassword if necessary, but it's not recommended
//       });

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('User registered successfully!'),
//       ));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Registration failed: $e'),
//       ));
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'dart:convert'; // For utf8
import 'package:crypto/crypto.dart'; // For sha256
import 'dart:ui'; // For ImageFilter
import 'evstationform.dart'; // Import the EVStationForm
import 'vehicleform.dart'; // Import the AddVehicleForm

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration"),
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
                  color: Colors.white.withOpacity(
                      0.2), // Semi-transparent white for glass effect
                  borderRadius: BorderRadius.circular(10.0),
                  border:
                      Border.all(color: Colors.green, width: 2), // Green border
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
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
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        hint: Text('Select Role'),
                        items: ['EV Owner', 'Station Owner'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: TextStyle(
                              color: Colors.green[700]), // Dark green label
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black), // Black underline
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _registerUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 129, 224, 134), // Dark green button
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16), // Black text
                        ),
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

  void _registerUser() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // Authenticate the user with Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hash the password with sha256 for Firestore storage (optional)
      var bytes = utf8.encode(password);
      var hashedPassword = sha256.convert(bytes).toString();

      String userId = userCredential.user!.uid;

      // Reference to the Firestore user collection
      CollectionReference usersRef =
          FirebaseFirestore.instance.collection('users');

      // Store the user in Firestore using the userId as the document ID
      await usersRef.doc(userId).set({
        'userId': userId, // Same as Firebase Authentication user UID
        'name': name,
        'email': email,
        'role': _selectedRole, // 'EV Owner' or 'Station Owner'
        'registeredAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully!'),
      ));

      // Navigate to EVStationForm if 'Station Owner', otherwise to AddVehicleForm
      if (_selectedRole == 'Station Owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EVStationForm()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AddVehicleForm(
                    userId: '',
                  )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed: $e'),
      ));
    }
  }
}
