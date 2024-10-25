import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for making phone calls

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    // Get the current user
    user = _auth.currentUser;
  }

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title above the profile photo
              Text(
                'Your Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Display avatar or placeholder
              CircleAvatar(
                radius: 60,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                backgroundColor: Colors.grey.shade200,
              ),
              SizedBox(height: 30),

              // Card to display email and password with full width
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: double.infinity, // Set the width to full
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? 'No email found',
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Password:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '********', // Masked password for security
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Title for other team members
              Text(
                "Other Team Members",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Full-width card for team members
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: double.infinity, // Set the width to full
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('John Doe'),
                        subtitle: Text('9876543210'),
                        trailing: IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () => _makePhoneCall('9876543210'),
                        ),
                      ),
                      ListTile(
                        title: Text('Jane Smith'),
                        subtitle: Text('8765432109'),
                        trailing: IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () => _makePhoneCall('8765432109'),
                        ),
                      ),
                      ListTile(
                        title: Text('Rahul Sharma'),
                        subtitle: Text('9988776655'),
                        trailing: IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () => _makePhoneCall('9988776655'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
