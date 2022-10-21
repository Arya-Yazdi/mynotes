import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Column(
        children: [
          // - Text
          const Text("We have sent you an email verification."),

          // - Text
          const Text(
              "If you haven't received an email verification, press the button below."),

          // - TextButton: Send email verification
          // Button which sends verification eamil to user.
          TextButton(
            onPressed: () {
              // Send verification email to user.
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
            },
            child: const Text("Send email verification"),
          ),

          // - TextButton: Restart
          TextButton(
            onPressed: () {
              // Log user out and redirect user to "register" view.
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
