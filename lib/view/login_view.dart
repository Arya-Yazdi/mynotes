import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return Column(
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
              final credential = await FirebaseAuth.instance
                  .signInWithEmailAndPassword(email: email, password: password);
              print('USER SUCCESSFULLY LOGGED IN');
              print(credential);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('USER NOT FOUND');
              } else if (e.code == 'wrong-password') {
                print('WRONG PASSWORD');
              }
            }
          },
          // Write "register" on button.
          child: const Text("Login"),
        ),
      ],
    );
  }
}
