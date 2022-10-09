import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
// Create text controller to store user's inputted email.
  late final TextEditingController _email;
  // Create text controller to store user's inputted password.
  late final TextEditingController _password;

  @override
  void initState() {
    // Store user's inputted email.
    _email = TextEditingController();

    // Store user's inputted password.
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose user's inputted login information after authentication has been completed.
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          // Create input field for user to enter their email.
          TextField(
            // Send user's input to the text controller.
            controller: _email,
            // Use "email" keyboard when user taps on input.
            keyboardType: TextInputType.emailAddress,
            // Don't autocorect email input.
            autocorrect: false,
            // Use "email" as placeholder text.
            decoration: const InputDecoration(hintText: "email"),
          ),

          // Create input field for user to enter their password.
          TextField(
            // Send user's input to the text controller.
            controller: _password,
            // Hide password when typed.
            obscureText: true,
            // Don't suggest or autocorect password input.
            enableSuggestions: false,
            autocorrect: false,
            // Use "password" as placeholder text.
            decoration: const InputDecoration(hintText: "password"),
          ),

          // Create a button.
          TextButton(
            // When the button is pressed ...
            onPressed: () async {
              // Get email from text controller.
              final email = _email.text;
              // Get password from text controller.
              final password = _password.text;
              try {
                // Log user in.
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                // Get current user from FirebaseAuth
                final user = FirebaseAuth.instance.currentUser;
                // If user's email if verified...
                if (user?.emailVerified ?? false) {
                  // Send user to main page of application.
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                }
                // If user is not verified...
                else {
                  // Send user to "verify email" page.
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  await showErrorDialog(context, "User not found!");
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(context, "Wrong Password!");
                } else {
                  await showErrorDialog(context, "Error: ${e.code}");
                }
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            // Write "Login" on button.
            child: const Text("Login"),
          ),
          // Button which redirects users to register page.
          TextButton(
            onPressed: () {
              // Remove all previous routes and push the "register" route onto the screen.
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Not Registered Yet? Register Now"),
          )
        ],
      ),
    );
  }
}
