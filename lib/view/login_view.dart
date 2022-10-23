import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';

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

  // initState() is always called once at the very beginning.
  @override
  void initState() {
    // Store user's inputted email.
    _email = TextEditingController();

    // Store user's inputted password.
    _password = TextEditingController();
    super.initState();
  }

  // dispose() is always called once at the very end.
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
        // If state is "Logged Out"...
        if (state is AuthStateLoggedOut) {
          // If the exception in our "Logged Out" state is "UserNotFoundAuthException"...
          if (state.exception is UserNotFoundAuthException) {
            // Display error dialog.
            await showErrorDialog(
                context, 'Cannot find a user with the entered credentials.');
          }
          // Else if the exception in our "Logged Out" state is "WrongPasswordAuthException"...
          else if (state.exception is WrongPasswordAuthException) {
            // Display error dialog.
            await showErrorDialog(context, 'Wrong credentials.');
          }
          // Else if the exception in our "Logged Out" state is "WrongPasswordAuthException"...
          else if (state.exception is GenericAuthException) {
            // Display error dialog.
            await showErrorDialog(context, 'Something went wrong.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TEXT
              const Text('Please log into your account to access your notes.'),

              // TEXTFIELD: email.
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

              // TextField: password.
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

              // TEXTBUTTON: Login
              // Create a button which allows users to log in.
              TextButton(
                // When the button is pressed ...
                onPressed: () async {
                  // Get email from text controller.
                  final email = _email.text;
                  // Get password from text controller.
                  final password = _password.text;

                  // Get Get ahold of our "AuthBloc" and call AuthEventLogIn().
                  context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                },
                // Write "Login" on button.
                child: const Text("Login"),
              ),

              TextButton(
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventForgotPassword(email: null));
                  },
                  child: const Text('Forgot password?')),

              // TEXTBUTTON: Go to register page.
              // Button which redirects users to register page.
              TextButton(
                onPressed: () {
                  // Get Get ahold of our "AuthBloc" and call AuthEventShouldRegister().
                  // Direct user to "register" page.
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Not Registered Yet? Register Now"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
