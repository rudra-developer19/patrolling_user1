import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'SubmittedNotesPage.dart'; // Replace with your actual page

class InstantNotePage extends StatefulWidget {
  @override
  _InstantNotePageState createState() => _InstantNotePageState();
}

class _InstantNotePageState extends State<InstantNotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();
  Set<Polygon> _polygons = {};
  LatLng _selectedLocation = LatLng(24.1712, 72.4382);
  String _selectedArea = 'Subhash Nagar';
  File? _image;
  final picker = ImagePicker();

  List<String> _palanpurAreas = [
    'Subhash Nagar',
    'Brahmanpura',
    'Sarkari Vasahat',
    'Gayatri Nagar',
    'Santosh Nagar',
    'Ambika Society',
    'Zanzarada Road',
    'Ring Road',
    'Mota Deesa Road',
    'Railway Station Area',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAreaSelected(String area) {
    LatLng location;
    switch (area) {
      case 'Subhash Nagar':
        location = LatLng(24.1735, 72.4392);
        break;
      case 'Brahmanpura':
        location = LatLng(24.1748, 72.4405);
        break;
      case 'Sarkari Vasahat':
        location = LatLng(24.1759, 72.4418);
        break;
      default:
        location = LatLng(24.1712, 72.4382);
    }

    setState(() {
      _selectedLocation = location;
      _selectedArea = area;
      _polygons = {
        Polygon(
          polygonId: PolygonId(area),
          points: _createPolygonPoints(location),
          strokeColor: Colors.black,
          strokeWidth: 2,
          fillColor: Colors.black.withOpacity(0.15),
        ),
      };
    });

    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(location, 15.0));
    });
  }

  List<LatLng> _createPolygonPoints(LatLng center) {
    return [
      LatLng(center.latitude + 0.001, center.longitude - 0.001),
      LatLng(center.latitude + 0.001, center.longitude + 0.001),
      LatLng(center.latitude - 0.001, center.longitude + 0.001),
      LatLng(center.latitude - 0.001, center.longitude - 0.001),
    ];
  }

  Future<void> _pickImage(bool isCamera) async {
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitNote() async {
    String title = _titleController.text;
    String note = _noteController.text;

    if (title.isNotEmpty && note.isNotEmpty) {
      // Simulating note submission
      _titleController.clear();
      _noteController.clear();
      setState(() {
        _image = null;
        _polygons.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note Submitted Successfully!'),
        backgroundColor: Colors.black,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and mark the area!'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instant Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.note_alt_outlined, color: Colors.white),
            tooltip: 'View Submitted Notes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubmittedNotesPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Short Note',
                labelStyle: TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 15),

            // Image Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(false),
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(true),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Display selected image
            if (_image != null)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            SizedBox(height: 15),

            // Area Selector
            DropdownButtonFormField<String>(
              value: _selectedArea,
              onChanged: (newValue) => _onAreaSelected(newValue!),
              decoration: InputDecoration(
                labelText: 'Select Area',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _palanpurAreas.map<DropdownMenuItem<String>>((String area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Text(area, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
            SizedBox(height: 15),

            // Map
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 13.0,
                  ),
                  polygons: _polygons,
                  onMapCreated: (controller) {
                    _mapController.complete(controller);
                  },
                ),
              ),
            ),
            SizedBox(height: 15),

            // Submit Button
            ElevatedButton(
              onPressed: _submitNote,
              child: Text('Submit Note', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
