// View which lists all of users created notes and allows users to delete them.

import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialog/delete_dialog.dart';

// Function which takes in a note as a parameter.
typedef DeleteNoteCallBack = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  // Declare variable "notes" which stores all of users notes.
  final List<DatabaseNote> notes;

  // Initiate "DeleteNoteCallBack" function and name it "onDeleteNote"
  final DeleteNoteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    // Display a list of notes.
    return ListView.builder(
      itemCount: notes.length,
      // For each item in our ListView...
      itemBuilder: (context, index) {
        // Get current note from list as ListView iterates over list on notes.
        final note = notes[index];
        // Display the current note...
        return ListTile(
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
