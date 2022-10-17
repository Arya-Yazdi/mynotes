// Representing a note in Firestore

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
// Defining collection of storing note.
class CloudNote {
  // document id (note id).
  final String documentId;
  // Owner id.
  final String ownerUserId;
  // Note text.
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  // Declare constructor called "fromSnapShot" which allows firestore to return content of user's note.
  CloudNote.fromSnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
