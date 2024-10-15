import 'package:flutter/material.dart';
import 'tasks_page.dart'; // Import the TasksPage
import 'instant_note_page.dart'; // Import the InstantNotePage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Current selected index

  // List of pages for navigation
  final List<Widget> _pages = [
    TasksPage(), // Tasks screen
    InstantNotePage(), // Instant Note screen
    Center(child: Text('History Screen')), // Placeholder for History screen
    Center(child: Text('Profile Screen')), // Placeholder for Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Log out logic will go here
            },
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
        selectedItemColor: Colors.teal, // Color of the selected item
        unselectedItemColor: Colors.grey, // Color of the unselected items
        backgroundColor: Colors.white, // Background color of the bar
        type: BottomNavigationBarType.fixed, // Keeps items fixed in place
      ),
    );
  }
}
