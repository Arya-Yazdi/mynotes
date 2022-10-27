import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';
import 'package:mynotes/utilities/dialog/password_reset_email_sent_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          // If reset email was sent to user...
          if (state.hasSentEmail) {
            // Clear text (email) on screen typed by user in TextField.
            _controller.clear();
            // Show dialog to user that we have sent an email to them.
            await showPasswordResetSentDialog(context);
          }

          // If an exception was thrown when sending an password reset email to user.
          if (state.exception != null) {
            await showErrorDialog(
              context,
              context.loc.forgot_password_view_generic_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.forgot_password),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TEXT: Description.
              Text(context.loc.forgot_password_view_prompt),

              // TEXTFIELD: Enter email address.
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: context.loc.email_text_field_placeholder),
              ),

              // TEXTBUTTON: Send reset password email.
              TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: Text(context.loc.forgot_password_view_send_me_link)),

              // TEXTBUTTON: Back to login view.
              TextButton(
                  onPressed: () {
                    // Send user to login view.
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: Text(context.loc.forgot_password_view_back_to_login))
            ],
          ),
        ),
      ),
    );
  }
}
