// View which lists all of users created notes and allows users to delete them.

import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialog/delete_dialog.dart';

// Function which takes in a note as a parameter.
typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  // Declare variable "notes" which stores all of users notes.
  final Iterable<CloudNote> notes;

  // Initiate "NoteCallBack" function and name it "onDeleteNote"
  final NoteCallBack onDeleteNote;

  // Initiate NoteCallBack function and name it "onTap"
  final NoteCallBack onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Display a list of notes.
    return ListView.builder(
      itemCount: notes.length,
      // For each item in our ListView...
      itemBuilder: (context, index) {
        // Get current note from list as ListView iterates over list on notes.
        var note = notes.elementAt(index);
        // Display the current note...
        return ListTile(
          onTap: () {
            // Pass note to
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          // Add a "trash" icon next to each note that is lister so user's can delete that particular note.
          trailing: IconButton(
              // When trash icon is pressed...
              onPressed: () async {
                // Show dialog asking user if they are sure they want to delete their note.
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
