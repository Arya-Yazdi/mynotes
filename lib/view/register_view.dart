import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';

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
    // Bloc Listener listens and responds to different states.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // If state is "Registering"...
        if (state is AuthStateRegistering) {
          // If user's entered password is weak...
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak password');
          }
          // If user's email is already in use...
          else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use');
          }
          // If user's email is already in use...
          else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email.');
          }
          // If any other problem arises...
          else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: Column(
          children: [
            // - TextField: email.
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

            // - TextField: passsword.
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

            // - TextButton: Register.
            // Create a button.
            TextButton(
              // When the button is pressed ...
              onPressed: () async {
                // Get email from text controller.
                final email = _email.text;
                // Get password from text controller.
                final password = _password.text;
                // Register user.
                context
                    .read<AuthBloc>()
                    .add(AuthEventRegister(email, password));
              },
              // Write "register" on button.
              child: const Text("Register"),
            ),

            // - TextButton: Go to login page.
            // Button which loads "login screen" to user if they already have an account.
            TextButton(
                onPressed: () {
                  // Send user to login view.
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text("Already have an account? Login Here"))
          ],
        ),
      ),
    );
  }
}
