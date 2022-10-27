import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

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
            await showErrorDialog(
                context, context.loc.register_error_weak_password);
          }
          // If user's email is already in use...
          else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
                context, context.loc.register_error_email_already_in_use);
          }
          // If user's email is already in use...
          else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
                context, context.loc.register_error_invalid_email);
          }
          // If any other problem arises...
          else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, context.loc.register_error_generic);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.register),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TEXT:
              Text(context.loc.register_view_prompt),

              // TEXTFIELD: Input email.
              TextField(
                // Send user's input to the text controller.
                controller: _email,
                // Use "email" keyboard when user taps on input.
                keyboardType: TextInputType.emailAddress,
                // Don't autocorect email input.
                autocorrect: false,
                autofocus: true,
                // Use "email" as placeholder text.
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
              ),

              // TEXTFIELD: Input password.
              TextField(
                // Send user's input to the text controller.
                controller: _password,
                // Hide password when typed.
                obscureText: true,
                // Don't suggest or autocorect password input.
                enableSuggestions: false,
                autocorrect: false,
                // Use "password" as placeholder text.
                decoration: InputDecoration(
                    hintText: context.loc.password_text_field_placeholder),
              ),

              Center(
                child: Column(
                  children: [
                    // TEXTBUTTON: Register.
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
                      child: Text(context.loc.register),
                    ),

                    // TEXTBUTTON: Go to login page.
                    TextButton(
                        onPressed: () {
                          // Send user to login view.
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        child:
                            Text(context.loc.register_view_already_registered))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
