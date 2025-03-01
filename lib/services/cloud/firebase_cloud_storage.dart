//// Handles everything related to storing/editing etc. user's notes.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Get the "notes" collection from Firestore. (Like a stream which you can read from and write to)
  final notes = FirebaseFirestore.instance.collection("notes");

  // Define Function to create a note in our "notes" collection from Firestore given user's id.
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    // Add a new note to our "notes" collection.
    final document = await notes.add({
      // Set the ownerUserIdFieldName as user's id.
      ownerUserIdFieldName: ownerUserId,
      // Set note text.
      textFieldName: "",
    });

    // Get the note created.
    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  // REASON FOR COMMENTING OUT: NOT BEING USED IN APPLICATION.
  // // Function which gets user's note from Firestore given the user's id.
  // Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
  //   try {
  //     // From notes 'Stream'
  //     return await notes
  //         // Filter the collection to only have documents where "ownerUserIdFieldName" is equal to "ownerUserId".
  //         .where(
  //           ownerUserIdFieldName,
  //           isEqualTo: ownerUserId,
  //         )
  //         // Get those documents which pass the "where" filter.
  //         .get()
  //         // Then map each document(each note) to a "CloudNote" and fill in appropriate fields
  //         // with content taken from the doc(the note).
  //         .then(
  //           (value) => value.docs.map((doc) => CloudNote.fromSnapShot(doc)),
  //         );
  //   } catch (e) {
  //     throw CouldNotGetAllNotesException();
  //   }
  // }

  // Function which deletes user's notes.
  Future<void> deleteNote({required String documentId}) async {
    try {
      // Get the document specified by its documentId and update its "textFieldName"
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // Function which updates user's notes (so they can edit)
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      // Get the document specified by its documentId and update its "textFieldName"
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // Stream which allows us to get user's notes live (Is aware of changes eg. user adds/deleted a note)
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        // "snapshots()": Get all changes as they are happening live.
        .snapshots()
        // "map((event) => event.docs": Get the documents(notes) inside that snapshot (event/list of notes).
        .map((event) => event.docs
            // Map those documents(notes) and make each a CloudNote(so we have access to each note).
            .map((doc) => CloudNote.fromSnapShot(doc)));
    return allNotes;
  }

  // Make "FirebaseCloudStorage" a singleton so that only one instance of it can be created in the entire
  // application. In this case the single instance is going to be called "_shared".  The factory allows us to
  // access this single instance ("_shared") of our FirebaseCloudStorage by simply calling FirebaseCloudStorage()
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
