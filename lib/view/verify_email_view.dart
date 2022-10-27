import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

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
        title: Text(context.loc.verify_email),
      ),
      body: Column(
        children: [
          // - Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(context.loc.verify_email_view_prompt),
          ),

          // - TextButton: Send email verification
          // Button which sends verification eamil to user.
          TextButton(
            onPressed: () {
              // Send verification email to user.
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
            },
            child: Text(context.loc.verify_email_send_email_verification),
          ),

          // - TextButton: Restart
          TextButton(
            onPressed: () {
              // Log user out and redirect user to "register" view.
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: Text(context.loc.restart),
          )
        ],
      ),
    );
  }
}
