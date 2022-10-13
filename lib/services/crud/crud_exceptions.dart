//// CRUD EXCEPTIONS:

// Defining Exception for when database is already opened.
class DatabaseAlreadyOpenException implements Exception {}

// Defining Exception for when we can't get documents directory path.
class UnableToGetDocumentsDirectoryException implements Exception {}

// Defining Exception for when the database is not open.
class DatabaseIsNotOpenException implements Exception {}

// Defining Exception for when user could not be deleted from database.
class CouldNotDeleteUserException implements Exception {}

// Defining Exception for when the database is not open.
class UserAlreadyExistsException implements Exception {}

// Defining Exception for when user is not found in the database..
class CouldNotFindUserException implements Exception {}

// Defining Exception for when note could not be deleted from database.
class CouldNotDeleteNoteException implements Exception {}

// Defining Exception for when note could not found in database.
class CouldNotFindNoteException implements Exception {}

// Defining Exception for when note could not be updated.
class CouldNotUpdateNoteException implements Exception {}
