// //// Handles everything related to storing/editing etc. user's notes.
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:mynotes/extentions/list/filter.dart';
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;

// // Creating a CRUD service to work with our databse.
// class NoteService {
//   // Create a variable called "_db" of type Database.
//   Database? _db;

//   // Declare a variable which stores a list of notes and call it "_notes". (This will be used for caching)
//   List<DatabaseNote> _notes = [];

//   DatabaseUser? _user;

//   // Allows us to listen to the stream more than once.
//   NoteService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }

//   // Make "NoteService" a singleton so that only one instance of it can be created in the entire application.
//   // In this case the single instance is going to be called "_shared".  The factory allows us to
//   // access this single instance ("_shared") of our NoteService by simply calling NoteService()
//   static final NoteService _shared = NoteService._sharedInstance();
//   factory NoteService() => _shared;

//   // Declare a stream controller. <List<DatabaseNote>> is type of data that the stream contains.
//   // .broadcast() allows you to listen to the stream more than once.
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   // Getter function which gets all notes form the "_notesStreamController"
//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         // Get the current user.
//         final currentUser = _user;

//         // If there is a user...
//         if (currentUser != null) {
//           // Return a boolean to the ".filter" function.
//           return note.userId == currentUser.id;
//         } else {
//           // Throw exception if there is no user set.
//           throw UserShouldBeSetBeforeReadingAllNotesException();
//         }
//       });

//   // Function which gets/creates user in our databased based on their email which
//   // they used to registed/login into our app using firebase.
//   // This function will be used so we can show only the notes associated to the logged in user.
//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       // Get user from database based on their email.
//       final user = await getUser(email: email);

//       if (setAsCurrentUser) {
//         _user = user;
//       }

//       return user;
//     } on CouldNotFindUserException {
//       // Create a user if there is no user with the associated email in our database.
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       // "rethrow" shows traceback of stack. Allows you to debug later on if
//       // an exception arises which you have not handled.
//       rethrow;
//     }
//   }

//   // Declare function which can read and chache the notes to "_notes"
//   // and the "notesStreamController" Stream controller
//   Future<void> _cacheNotes() async {
//     // Get all notes from the database.
//     final allNotes = await getAllNotes();

//     // Store/Cache all notes into the _notes cache.
//     _notes = allNotes.toList();

//     // Store/Cache changes to _notes at _notesStreamController.
//     _notesStreamController.add(_notes);
//   }

//   // Function which checks to see if databsae is open or not(throws an exception).
//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   // Function which ensures database is open.
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       // Call our open() function to open the database.
//       await open();
//     }
//     // Don't do anything if "DatabaseAlreadyOpenException" is thrown.
//     on DatabaseAlreadyOpenException {
//       // Do nothing (no code).
//     }
//   }

//   // Function which opens/initiates database.
//   Future<void> open() async {
//     // Throw Exception if database is already open.
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }

//     // Try to get App's document directory path.
//     try {
//       // Get App's document directory path.
//       final docsPath = await getApplicationDocumentsDirectory();

//       // Create path where our database is located.
//       final dbPath = join(docsPath.path, dbName);

//       // Open the database and store it in a variable named "db"
//       // note: openDatabase(dbPath) Creates the database if it does not exist.
//       final db = await openDatabase(dbPath);

//       // Assign opened "db" to our local database instance.
//       _db = db;

//       // Execute the "createUserTable" (USER TABLE) SQL command in our app's database.
//       await db.execute(createUserTable);

//       // Execute the "createNoteTable" (NOTE TABLE) SQL command in our app's database.
//       await db.execute(createNoteTable);
//     } on MissingPlatformDirectoryException {
//       // Throw exception if unable to get document directory.
//       throw UnableToGetDocumentsDirectoryException();
//     }

//     // Cache all user notes from database;
//     await _cacheNotes();
//   }

//   // Function which closes the database.
//   Future<void> close() async {
//     // Set "db" Variable to our local db.
//     final db = _db;

//     // Throw Exception when the database is not already opened.
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       // Close the database;
//       await db.close();

//       // Reset local database and set it to null.
//       _db = null;
//     }
//   }

//   // Function which deletes user from databases given their email.
//   Future<void> deleteUser({required String email}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get database.
//     final db = _getDatabaseOrThrow();

//     // Delete user of given email from the database.
//     // SQL: DELETE FROM user(usertable) where email = '<email.toLowerCase()>'.
//     // delete() returns number of rows deleted from table.
//     final deletedCount = await db.delete(userTable,
//         where: "email = ?", whereArgs: [email.toLowerCase()]);

//     // Ensure user was successfully deleted from the database.
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   // Function which adds user to the database.
//   Future<DatabaseUser> createUser({required String email}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get the database.
//     final db = _getDatabaseOrThrow();

//     // Query database to check whether user already exists or not.
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     // Throw exception if user already exists (as we can't add a new user if they already exist)
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }

//     // Insert user into the user table and set its "email" to the user's email.
//     // insert() returns the id of the last inserted row.
//     final userId =
//         await db.insert(userTable, {emailColumn: email.toLowerCase()});

//     return DatabaseUser(id: userId, email: email);
//   }

//   // Function which gets the User from the database using their email.
//   Future<DatabaseUser> getUser({required String email}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get the current app's database.
//     final db = _getDatabaseOrThrow();

//     // Query database and get the user id based on user's email.
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     // Throw Exception is user could not be found in the databse.
//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       // Return user as DatabaseUser where values of columns are taken from the
//       // first row that is returned by the SQL query.
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   // Function which allows user to create/store notes.
//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get the current app's database
//     final db = _getDatabaseOrThrow();

//     // Get user from database using their email.
//     final dbUser = await getUser(email: owner.email);

//     // Ensure dbUser is the actual person who want to store the note. (Safety reasons)
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }

//     // Declare variable as an empty string to store user's note (empty string will be overridden
//     // by user's actual text).
//     const text = "";

//     // Insert user's note into the note table.
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     // store DatabaseNote instance of the users note ina variable called "notes".
//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     // Cache newly added note to "_notes".
//     _notes.add(note);

//     // Cache newly updated "_notes" list to "_notesStreamController" Stream Controller.
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   // Function which allows user to delete their note.
//   Future<void> deleteNote({required int id}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get current app's database.
//     final db = _getDatabaseOrThrow();

//     // Delete note from the "note" table.
//     final deleteCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     // Throw Exception if note could not be deleted.
//     if (deleteCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       // Remove deleted note from local cache.
//       // Code reads as: Remove note from _notes where note.id is equal to id.
//       _notes.removeWhere((note) => note.id == id);

//       // Update Stream Controller
//       _notesStreamController.add(_notes);
//     }
//   }

//   // Function which deleted ALL notes from the database (not really sure why you need this function...)
//   Future<int> deleteAllNotes({required int id}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get current app's database.
//     final db = _getDatabaseOrThrow();

//     // Delete all notes inside the "note" table.
//     final numberOfDeletions = await db.delete(noteTable);

//     // Update _notes cache and set it to an empty list as all notes would have been deleted.
//     _notes = [];

//     // Update Stream Controller.
//     _notesStreamController.add(_notes);

//     // Return number of rows/notes deleted.
//     return numberOfDeletions;
//   }

//   // Function which fetches a specific note based on its id.
//   Future<DatabaseNote> getNote({required int id}) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get current app's database.
//     final db = _getDatabaseOrThrow();

//     // Get the note from the database based on its id.
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     // Throw Exception if note could not be found based on its id.
//     if (notes.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       // Get note from database.
//       final note = DatabaseNote.fromRow(notes.first);

//       // Update note in "_notes" cache to ensure note is not outdated.
//       // Remove specified note from the cache.
//       _notes.removeWhere((note) => note.id == id);

//       // Add updated note into the cache.
//       _notes.add(note);

//       // Update Stream Controller.
//       _notesStreamController.add(_notes);

//       return note;
//     }
//   }

//   // Function which fetches all notes. Returns a list of "DatabaseNote".
//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get current app's database.
//     final db = _getDatabaseOrThrow();

//     // Get all notes from the databse.
//     final notes = await db.query(noteTable);

//     // Maps each note returned to a DatabaseNote and returns an iterable.
//     return notes.map((notesRow) => DatabaseNote.fromRow(notes.first));
//   }

//   // Function which allows user to update their notes.
//   Future<DatabaseNote> updateNote({
//     // To grab existing note (so the note can be edited)
//     required DatabaseNote note,
//     // Text which the user is going to change the note text to.
//     required String text,
//   }) async {
//     // Ensure database is already opened.
//     await _ensureDbIsOpen();

//     // Get current app's database.
//     final db = _getDatabaseOrThrow();

//     // Get note from database to ensure it exists (getNote() function checks if note exists or not.)
//     await getNote(id: note.id);

//     // Update text of note stored in database.
//     final updatesCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0) {
//       // Throw exception if note could not be updated.
//       throw CouldNotUpdateNoteException();
//     } else {
//       // Get updated note.
//       final updatedNote = await getNote(id: note.id);

//       // Update note in "_notes" cache to ensure note is not outdated.
//       // Remove specified note from the cache.
//       _notes.removeWhere((note) => note.id == updatedNote.id);

//       // Add updated note into the cache.
//       _notes.add(updatedNote);

//       // Update Stream Controller.
//       _notesStreamController.add(_notes);

//       return updatedNote;
//     }
//   }
// }

// // Declaring the "user" table in Database in dart (and some added functionalitied).
// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({required this.id, required this.email});

//   // Map<String, Object?> is what is returned by the databate (It represent each row in the table)
//   // : id = map[idColumn]. Creates an instance of DatabaseUser(the ":" is shorthand notation).
//   // Inside the map there should be a column called the value of idColumn, so set the
//   // id of the DatabaseUser constructor to that value thats in the column.
//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   // Usefull function if you need to print all users from database to the debug console.
//   @override
//   String toString() => "Person, ID = $id, EMAIL = $email";

//   // Overrides the == operator. So we can compare two objects of
//   //type DatabaseUser with each other using their id's.
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   // Related to the override above. Tells dart to compare using the id's hashcode.
//   @override
//   int get hashCode => id.hashCode;
// }

// // Declaring the "note" table in Database in dart (and some added functionalitied).
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote(
//       {required this.id,
//       required this.userId,
//       required this.text,
//       required this.isSyncedWithCloud});

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         // If map[isSyncedWithCloudColumn] is 1 return true, else return false.
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   // Usefull function if you need to print all users from database to the debug console.
//   @override
//   String toString() =>
//       "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

//   // Overrides the == operator. So we can compare two objects of
//   //type DatabaseUser with each other using their id's.
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   // Related to the override above. Tells dart to compare using the id's hashcode.
//   @override
//   int get hashCode => id.hashCode;
// }

// //// CONSTANTS:
// // Name of our Database file (filename).
// const dbName = "notes.db";

// // Name of the notes table in the database.
// const noteTable = "note";

// // Name of the users table in the database.
// const userTable = "user";

// // Name of column storing the user "id" in the database.
// const idColumn = "id";

// // Name of column storing the user's "email" in the database.
// const emailColumn = "email";

// // Name of column storing the user's "user_id" in the database.
// const userIdColumn = "user_id";

// // Name of column storing the user's "text" in the database.
// const textColumn = "text";

// // Name of column storing "is_synced_with_cloud" in the database.
// const isSyncedWithCloudColumn = "is_synced_with_cloud";

// // Declare "createUserTable" variable to SQL code which creates the "User" table in our dataabse.
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//           "id"	INTEGER NOT NULL,
//           "email"	TEXT NOT NULL UNIQUE,
//           PRIMARY KEY("id" AUTOINCREMENT)
//         )''';

// // Declare "createNoteTable" variable to SQL code which creates the "User" table in our dataabse.
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       )''';
