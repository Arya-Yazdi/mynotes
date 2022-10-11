import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
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
      body: const Text("Hello World"),
    );
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
