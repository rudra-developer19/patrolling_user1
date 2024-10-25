import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SubmittedNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submitted Notes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('instant_notes').orderBy('submitted_at', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No notes have been submitted yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var note = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(note['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['note']),
                      SizedBox(height: 4.0),
                      Text(
                        'Location: (${note['location'].latitude}, ${note['location'].longitude})',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Submitted on: ${DateFormat.yMMMd().add_jm().format(note['submitted_at'].toDate())}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    // If you want to show more details when a note is tapped
                    // You can navigate to a detailed page or show a dialog
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
