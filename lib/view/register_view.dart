import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
                // Registed user using firebase.
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                // Send verification email to the user's email
                await AuthService.firebase().sendEmailVerification();

                // Reroute user to "verifyEmail" view.
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "Weak Password.");
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "Email is already in use.");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Invalid Email Address.");
              } on GenericAuthException {
                await showErrorDialog(context, "Failed to Register");
              }
            },
            // Write "register" on button.
            child: const Text("Register"),
          ),

          // Button which loads "login screen" to user if they already have an account.
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already have an account? Login Here"))
        ],
      ),
    );
  }
}
