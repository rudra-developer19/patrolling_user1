import 'package:flutter/material.dart';
import 'HistoryPage.dart';
import 'login_page.dart';
import 'tasks_page.dart'; // Import the TasksPage
import 'instant_note_page.dart'; // Import the InstantNotePage
import 'profile_page.dart'; // Import the ProfilePage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Current selected index

  List<Widget> _pages = []; // List for pages

  @override
  void initState() {
    super.initState();
    // Initialize the _pages list inside initState
    _pages = [
      TasksPage(),       // Tasks screen
      InstantNotePage(), // Instant Note screen
      HistoryPage(),     // History screen
      ProfilePage(),     // Profile screen with avatar upload
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Show a confirmation dialog before logging out
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                // Here you can add your logout logic if needed
                // For example: FirebaseAuth.instance.signOut();

                // Navigate back to LoginPage
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout method
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement_rounded),
            label: 'Instant Note',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected item
        onTap: _onItemTapped, // Handle item tap
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
      