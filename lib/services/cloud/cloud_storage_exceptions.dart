//// CLOUD STORAGE/CRUD EXCEPTIONS:

// Define "Super Class" for all "Cloud Storage Exceptions" so we can group relevant exceptions together.
class CloudStorageException implements Exception {
  const CloudStorageException();
}

// Exception for when firestore can not successfully create a note.
class CouldNotCreateNoteException extends CloudStorageException {}

// Exception for when firestore can not retrieve all user's note successfully.
class CouldNotGetAllNotesException extends CloudStorageException {}

// Exception for when firestore can not update user's note successfully.
class CouldNotUpdateNoteException extends CloudStorageException {}

// Exception for when firestore can not delete user's note successfully.
class CouldNotDeleteNoteException extends CloudStorageException {}
