// Main view of the application where users can see the notes they have created.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialog/logout_dialog.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/view/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Create a variable of type FirebaseCloudStorage and name the variable  "_noteService".
  late final FirebaseCloudStorage _noteService;

  // Getter Function which gets user's id from firebase.
  String get userId => AuthService.firebase().currentUser!.id;

  // initState() is always called once at the very beginning.
  @override
  void initState() {
    // Create an instance of our FirebaseCloudStorage.
    _noteService = FirebaseCloudStorage();

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
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                    if (shouldLogOut) {
                      // Log user out.
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
        body: StreamBuilder(
          // Assign stream to our "allNotes" stream located in our "_noteService".
          stream: _noteService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              // When waiting for stream to return all of user's notes...
              // Or when stream has returned all user's notes...
              case ConnectionState.waiting:
              case ConnectionState.active:
                // If the "stream: _noteService.allNotes" contains data and is not empty...
                if (snapshot.hasData) {
                  // Get all of its data (get the list of notes / all notes)
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  // List all notes and allow users to delete them.
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _noteService.deleteNote(
                          documentId: note.documentId);
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
        ));
  }
}
