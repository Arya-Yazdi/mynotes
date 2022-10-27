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
import 'package:mynotes/extentions/buildcontext/loc.dart';

// Extension to get the numebr of notes a user has.
extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

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
          title: StreamBuilder<int>(
            // Get number of notes a user has.
            stream: _noteService.allNotes(ownerUserId: userId).getLength,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                final text = context.loc.notes_title(noteCount);
                return Text(text);
              } else {
                return const Text('');
              }
            },
          ),
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
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                }
              },

              // Called when PopupMenuButton (three dots) is clicked.
              // itemBuilder calls PopupMenuItem to get the items to show in the dropdown list.
              itemBuilder: (context) {
                return [
                  // Add a new item to dropdown button.
                  PopupMenuItem<MenuAction>(
                    // Value of item is MenuAction (from the enum above) logout.
                    value: MenuAction.logout,

                    // text of the item should say "logout"
                    child: Text(context.loc.logout_button),
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
