import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InstantNotePage extends StatefulWidget {
  @override
  _InstantNotePageState createState() => _InstantNotePageState();
}

class _InstantNotePageState extends State<InstantNotePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();
  Set<Polygon> _polygons = {};
  LatLng _selectedLocation = LatLng(24.1712, 72.4382); // Default to Palanpur's coordinates
  String _selectedArea = 'Subhash Nagar'; // Set a default area
  File? _image; // For storing the image
  final picker = ImagePicker();

  // List of Palanpur areas for the catalog
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
    // Add more areas as needed
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Function to handle area selection
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
      case 'Gayatri Nagar':
        location = LatLng(24.1766, 72.4425);
        break;
      case 'Santosh Nagar':
        location = LatLng(24.1772, 72.4432);
        break;
      case 'Ambika Society':
        location = LatLng(24.1785, 72.4446);
        break;
      case 'Zanzarada Road':
        location = LatLng(24.1801, 72.4460);
        break;
      case 'Ring Road':
        location = LatLng(24.1822, 72.4479);
        break;
      case 'Mota Deesa Road':
        location = LatLng(24.1833, 72.4490);
        break;
      case 'Railway Station Area':
        location = LatLng(24.1852, 72.4501);
        break;
      default:
        location = LatLng(24.1712, 72.4382); // Default Palanpur location
    }

    setState(() {
      _selectedLocation = location;
      _selectedArea = area;
      _polygons = {
        Polygon(
          polygonId: PolygonId(area),
          points: _createPolygonPoints(location),
          strokeColor: Colors.blue,
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.15),
        ),
      };
    });

    // Zoom in to the selected area
    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(location, 15.0));
    });
  }

  // Function to create polygon points for the selected area
  List<LatLng> _createPolygonPoints(LatLng center) {
    return [
      LatLng(center.latitude + 0.001, center.longitude - 0.001),
      LatLng(center.latitude + 0.001, center.longitude + 0.001),
      LatLng(center.latitude - 0.001, center.longitude + 0.001),
      LatLng(center.latitude - 0.001, center.longitude - 0.001),
    ];
  }

  // Function to pick an image from the gallery or camera
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

  // Function to submit the note to Firebase
  Future<void> _submitNote() async {
    String title = _titleController.text;
    String note = _noteController.text;

    if (title.isNotEmpty && note.isNotEmpty) {
      // Upload the note with location, image (if exists), and timestamp to Firebase
      final docRef = FirebaseFirestore.instance.collection('instant_notes').add({
        'title': title,
        'note': note,
        'location': GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
        'submitted_at': Timestamp.now(),
      });

      // If an image is selected, upload it separately
      if (_image != null) {
        // Add image upload code here if needed, for example:
        // await FirebaseStorage.instance.ref().child('notes_images/$docRef').putFile(_image);
      }

      // Clear the form after submission
      _titleController.clear();
      _noteController.clear();
      setState(() {
        _image = null;
        _polygons.clear(); // Clear polygons after submission
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note Submitted Successfully!'),
      ));
    } else {
      // Show an error if any required field is missing
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the fields and mark the area!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instant Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Floating Action Button for adding a new note
              FloatingActionButton(
                onPressed: () {
                  // Logic to show the input fields for adding a new note
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                labelText: 'Short Note',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(false),
                              icon: Icon(Icons.photo_library),
                              label: Text('Pick from Gallery'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _pickImage(true),
                              icon: Icon(Icons.camera_alt),
                              label: Text('Take a Photo'),
                            ),
                            if (_image != null)
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                ),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                            SizedBox(height: 10),
                            DropdownButton<String>(
                              value: _selectedArea,
                              onChanged: (newValue) {
                                if (newValue != null && newValue != 'Select Area') {
                                  _onAreaSelected(newValue);
                                  setState(() {
                                    _selectedArea = newValue; // Update the selected area
                                  });
                                }
                              },
                              items: _palanpurAreas.map<DropdownMenuItem<String>>((String area) {
                                return DropdownMenuItem<String>(
                                  value: area,
                                  child: Text(area),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _submitNote,
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Icon(Icons.add),
              ),
              SizedBox(height: 10),
              // Display the map with the selected area
              Container(
                height: 300,
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
            ],
          ),
        ),
      ),
    );
  }
}
