import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/view/login_view.dart';
import 'package:mynotes/view/notes/create_update_note_view.dart';
import 'package:mynotes/view/notes/notes_view.dart';
import 'package:mynotes/view/register_view.dart';
import 'package:mynotes/view/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Create a Bloc Provider which takes in our "AuthBloc" Bloc.
      home: BlocProvider<AuthBloc>(
        // Call our "AuthBloc" with "FirebaseAuthProvider" as its argument.
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNewNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // context.read<AuthBloc>(): Get ahold of our "AuthBloc" from "context".
    // .add(const AuthEventInitialize()): Communicate with our AuthBloc (.add(), and tell it to
    // call AuthEventInitialize().
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // If state's "isLoading" parameter is true...
        if (state.isLoading) {
          // Show an overlay.
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment...',
          );
        } else {
          // Hide the overlay.
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        // If user is fully logged in...
        if (state is AuthStateLoggedIn) {
          // Route user to "NotesView".
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
