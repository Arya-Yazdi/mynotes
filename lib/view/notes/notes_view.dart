// Main view of the application where users can see the notes they have created.
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/view/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Getter Function which gets user's email from firebase.
  String get userEmail => AuthService.firebase().currentUser!.email;

  // Create a variable of type NoteService and name the variable  "_noteService".
  late final NoteService _noteService;

  // initState() is always called once at the very beginning.
  @override
  void initState() {
    // Create an instance of our NoteService.
    _noteService = NoteService();

    // Open/Initialize database.
    _noteService.open();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Notes"),
          // Display Something after "Title" in app bar.
          actions: [
            // Display a "+" plus icon. Allows user's to add new note.
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNewNoteRoute);
                },
                icon: const Icon(Icons.add)),

            // Display dropdown menu button option (three dots etc.)
            PopupMenuButton<MenuAction>(
              // When the ITEM in the menu button dropdown is tapped on...
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    // Call ShowlogOutDialog function and await confirmation.
                    final shouldLogOut = await showLogOutDialog(context);

                    // If shouldLogOut is true...
                    if (shouldLogOut) {
                      // Log user out.
                      await AuthService.firebase().logOut();

                      // Remove all routes taken by user and take then to login view..
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    }
                }
              },

              // Called when PopupMenuButton (three dots) is clicked.
              // itemBuilder calls PopupMenuItem to get the items to show in the dropdown list.
              itemBuilder: (context) {
                return const [
                  // Add a new item to dropdown button.
                  PopupMenuItem<MenuAction>(
                    // Value of item is MenuAction (from the enum above) logout.
                    value: MenuAction.logout,

                    // text of the item should say "logout"
                    child: Text("Log out"),
                  ),
                ];
              },
            )
          ],
        ),
        // Body of the notes view.
        // Cretae a FutureBuilder.
        body: FutureBuilder(
          // Get the current user from the database based on their email
          // or create them in the database if they don't yet exist.
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            // "snapshot.connectionState" shows Current state of connection
            // to the asynchronous Function (in this case our getOrCreateUser() Future.)
            switch (snapshot.connectionState) {
              // If asynchronous Function was successfully run...
              case ConnectionState.done:
                return StreamBuilder(
                  // Assign stream to our "allNotes" stream located in our "_noteService".
                  stream: _noteService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // When waiting for stream to return all of user's notes...
                      // Or when stream has returned all user's notes...
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        // If the "stream: _noteService.allNotes" contains data and is not empty...
                        if (snapshot.hasData) {
                          // Get all of its data (get the list of notes / all notes)
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          // List all notes and allow users to delete them.
                          return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _noteService.deleteNote(id: note.id);
                            },
                            // Allow user to edit note.
                            onTap: (note) {
                              Navigator.of(context).pushNamed(
                                createOrUpdateNewNoteRoute,
                                arguments: note,
                              );
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }

                      // In any other case...
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              // When asynchronous Function is being processed...
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
