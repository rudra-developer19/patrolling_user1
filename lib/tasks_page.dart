import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'task_model.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  XFile? _capturedImage;
  String? _downloadUrl;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showStartTaskDialog(PatrolTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 8,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Write a note',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openCamera,
                      child: Text('Open Camera', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showSubmitConfirmationDialog(task),
                      child: Text('Submit Task', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _capturedImage = image;
    });
  }

  void _showSubmitConfirmationDialog(PatrolTask task) {
    // Show confirmation dialog before submitting the task
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission', style: TextStyle(color: Colors.black)),
          content: Text('Do you want to submit this task or add more details?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              child: Text('Add More', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _showFinalSubmitDialog(task); // Show final confirmation dialog
              },
              child: Text('Submit', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showFinalSubmitDialog(PatrolTask task) {
    // Show a final dialog before submission
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Final Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to submit the task?', style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the final confirmation dialog
                _submitTask(task); // Proceed with task submission
              },
              child: Text('Yes, Submit', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTask(PatrolTask task) async {
    if (_capturedImage != null && _noteController.text.isNotEmpty) {
      String fileName = _capturedImage!.name;
      File imageFile = File(_capturedImage!.path);

      try {
        final storageRef = _storage.ref().child('uploads/$fileName');
        final uploadTask = storageRef.putFile(imageFile);
        await uploadTask;

        _downloadUrl = await storageRef.getDownloadURL();
        String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        await _firestore.collection('completed_tasks').add({
          'title': task.title,
          'note': _noteController.text,
          'photo_url': _downloadUrl,
          'submitted_at': dateTime,
        });

        // Immediately lock the task button and show tick mark animation
        setState(() {
          task.status = 'completed'; // Mark task as completed
        });

        // Show tick mark animation
        _showTickAnimation();
      } catch (e) {
        print("Error uploading image or submitting task: $e");
      }
    } else {
      // Show error if no photo or note is provided
      _showErrorDialog('Please add a note and take a photo before submitting.');
    }
  }

  void _showTickAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Task Completed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog after a short delay
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Close the tick animation dialog
    });
  }

  void _showErrorDialog(String message) {
    // Display an error dialog if submission criteria are not met
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: Colors.black)),
          content: Text(message, style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
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
        title: Text('Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<PatrolTask>>(
        future: _fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks available.', style: TextStyle(color: Colors.black)));
          }

          List<PatrolTask> tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              PatrolTask task = tasks[index];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    task.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    task.description,
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusIndicator(task.status),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: task.status == 'pending'
                            ? () => _showStartTaskDialog(task)
                            : null, // Disable button if task is completed
                        child: Text('Start Task', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Changed to black
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<PatrolTask>> _fetchTasks() async {
    // Mocked task data (in real use, fetch from Firebase or API)
    await Future.delayed(Duration(seconds: 2));
    return [
      PatrolTask(id: '1', title: 'Task 1', description: 'Description for task 1', status: 'pending'),
      PatrolTask(id: '2', title: 'Task 2', description: 'Description for task 2', status: 'pending'),
      PatrolTask(id: '3', title: 'Task 3', description: 'Description for task 3', status: 'pending'),
    ];
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.black;
        icon = Icons.hourglass_empty;
        break;
      case 'completed':
        color = Colors.black;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.black;
        icon = Icons.help;
    }

    return Icon(
      icon,
      color: color,
      size: 28.0,
    );
  }
}
