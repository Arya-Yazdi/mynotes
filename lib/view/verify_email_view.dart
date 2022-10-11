import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
          const Text("We have sent you an email verification."),
          const Text(
              "If you haven't received an email verification, press the button below."),
          // Button which sends verification eamil to user.
          TextButton(
            onPressed: () async {
              // Send verification email to user.
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send email verification"),
          ),

          TextButton(
            onPressed: () async {
              // Log user out.
              await AuthService.firebase().logOut();

              // redirect user to "register" view.
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
