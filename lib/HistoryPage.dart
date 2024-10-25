import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchCompletedTasks() async {
    QuerySnapshot snapshot = await _firestore.collection('completed_tasks').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCompletedTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No completed tasks found.', style: TextStyle(color: Colors.black)));
          }

          List<Map<String, dynamic>> completedTasks = snapshot.data!;

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              var task = completedTasks[index];
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
                    task['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Note: ${task['note']}', style: TextStyle(color: Colors.black54)),
                      SizedBox(height: 5),
                      Text('Submitted at: ${task['submitted_at']}', style: TextStyle(color: Colors.black54)),
                      SizedBox(height: 5),
                      if (task['photo_url'] != null)
                        Image.network(task['photo_url'], height: 100, width: 100, fit: BoxFit.cover),
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
}
