import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Getter Function which gets user's email from firebase.
  String get userEmail => AuthService.firebase().currentUser!.email!;

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

  // dispose() is always called once at the very end.
  @override
  void dispose() {
    // Close the database.
    _noteService.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main UI"),
          // Display Something after "Title" in app bar.
          actions: [
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
                      case ConnectionState.waiting:
                        return const Text("Waiting for all Notes to load...");
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

// Create "showLogOutDialog" Function to handle Logout Confirmation.
Future<bool> showLogOutDialog(BuildContext context) {
  // Show the alert Dialog (but the alert dialog needs to be created first).
  return showDialog<bool>(
    context: context,
    builder: (context) {
      // Create the Alert Dialog
      return AlertDialog(
        // Set its title.
        title: const Text("Sign Out"),
        // Set its message
        content: const Text("Are you sure you want to Sign Out?"),
        // Create actions which the user can take...
        actions: [
          // Create a "Cancel" button.
          TextButton(
              // When Cancel button is pressed...
              onPressed: () {
                // Return the value of false (to ShowDialog)
                Navigator.of(context).pop(false);
              },
              // Write "Cancel" on button.
              child: const Text("Cancel")),
          // Create a "Log out" button.
          TextButton(
              // When "log out" button is pressed...
              onPressed: () {
                // Return the value of true (to ShowDialog)
                Navigator.of(context).pop(true);
              },
              // Write "Log Out" on button.
              child: const Text("Log Out")),
        ],
      );
    },
    // If the user clicks on one of the action buttons, return its value,
    //else (if the user taps outside/the back button), return false (AKA cancel the Sign Out operation.)
  ).then((value) => value ?? false);
}
