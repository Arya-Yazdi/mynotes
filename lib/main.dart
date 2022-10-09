import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/view/login_view.dart';
import 'package:mynotes/view/register_view.dart';
import 'package:mynotes/view/verify_email_view.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView()
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // When Firebase is successfully initialized...
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              } else {
                // Show "Verify Email View" if user's email is not verified.
                return const VerifyEmailView();
              }
            } else {
              // Show "Login View" if user is null (user in not logged in)
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

// Delcare enumeration for "Popup Menu Button" (Dropdown menu button).
enum MenuAction { logout }

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
                    // Call signOut() function by FireBaseAuth and wait for future to complete.
                    await FirebaseAuth.instance.signOut();
                    // Remove all routes taken by user and take then to login route.
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
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

// Cretae "showLogOutDialog" Function to handle Logout Confirmation.
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
