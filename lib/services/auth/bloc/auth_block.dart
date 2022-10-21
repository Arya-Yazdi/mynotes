// (3) Bloc: Defining the bloc which handles user authentication. (The main logic [input + output])

import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

// Declaring our main Bloc for authentication.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Constructor which takes in a Authentication Provider (eg. Firebase)
  // Initial state of Bloc is set to "Loading (AuthStateLoading)"
  // Bloc Logic: For each event which UI sends, (authEvent) produce a state (AuthState). So that our UI can
  // then generate widgets / display views based on that state.
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // INITIALIZE EVENT: When we are initializing our Auth Provider (eg. firebase).
    on<AuthEventInitialize>(((event, emit) async {
      // Initialize our AuthProvider.
      await provider.initialize();
      // Get the current user from our auth provider.
      final user = provider.currentUser;
      // If user is not logged in...
      if (user == null) {
        // Set state to "Logged Out" and pass it no exceptions.
        emit(const AuthStateLoggedOut(null));
      }
      // If user is logged in but has not verified their email...
      else if (!user.isEmailVerified) {
        // Set state to "Needs Verification".
        emit(const AuthStateNeedsVerification());
      }
      // If user is logged in and their email is verified...
      else {
        // Set state to "Logged In".
        emit(AuthStateLoggedIn(user));
      }
    }));

    // LOG IN EVENT: When the user wants to log in.
    on<AuthEventLogIn>(((event, emit) async {
      // Get user's email.
      final email = event.email;
      // Get user's password.
      final password = event.password;
      // Try to log user in using our Auth Provider.
      try {
        // Get user if they could successfully log in.
        final user = await provider.logIn(email: email, password: password);
        // Set state to "Logged In".
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        // Set state to "Log Out" and pass in the exception.
        emit(AuthStateLoggedOut(e));
      }
    }));

    // LOG OUT EVENT: When the user wants to log out.
    on<AuthEventLogOut>(((event, emit) async {
      try {
        // Set state to "Loading".
        emit(const AuthStateLoading());
        // Log user out using our auth exception.
        await provider.logOut();
        // Set state to "Logged Out" and pass it no exceptions.
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        // Set state to "Log Out Failure".
        emit(AuthStateLogoutFailure(e));
      }
    }));
  }
}
