// (3) Bloc: Defining the bloc which handles user authentication. (The main logic [input + output])
// Bloc Logic: For each event which UI sends, (authEvent) produce a state (AuthState). So that our UI can
// then generate widgets / display views based on that state.

import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

// Declaring our main Bloc for authentication.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Constructor which takes in a Authentication Provider (eg. Firebase)
  // Initial state of Bloc is set to "Uninitialize (AuthStateUninitialized)"
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    //
    // INITIALIZE EVENT: When we are initializing our Auth Provider (eg. firebase).
    on<AuthEventInitialize>(((event, emit) async {
      // Initialize our AuthProvider.
      await provider.initialize();
      // Get the current user from our auth provider.
      final user = provider.currentUser;
      // If user is not logged in...
      if (user == null) {
        // Set state to "Logged Out".
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }
      // If user is logged in but has not verified their email...
      else if (!user.isEmailVerified) {
        // Set state to "Needs Verification".
        emit(const AuthStateNeedsVerification(isLoading: false));
      }
      // If user is logged in and their email is verified...
      else {
        // Set state to "Logged In".
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    }));

    //
    // REGISTER EVENT: For when user wants to register an account.
    on<AuthEventRegister>(
      (event, emit) async {
        // Get user's email.
        final email = event.email;
        // Get user's password.
        final password = event.password;
        try {
          // Register user.
          await provider.createUser(email: email, password: password);

          // Send email verification to the user.
          await provider.sendEmailVerification();

          // Set state to "AuthStateNeedsVerification".
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          // If exception occurs set state to "AuthStateRegistering" and pass state the exception
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );

    //
    // SHOULD REGISTER EVENT: For when user wants to to to the register page.
    on<AuthEventShouldRegister>(
      (event, emit) {
        emit(const AuthStateRegistering(isLoading: false, exception: null));
      },
    );

    //
    // LOG IN EVENT: When the user wants to log in.
    on<AuthEventLogIn>(((event, emit) async {
      // Set state to "AuthStateLoggedOut" and display loading dialog.
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingtext: 'Logging in...',
      ));
      // Get user's email.
      final email = event.email;
      // Get user's password.
      final password = event.password;
      // Try to log user in using our Auth Provider.
      try {
        // Get user if they could successfully log in.
        final user = await provider.logIn(email: email, password: password);
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));

        // If user's email is not verified...
        if (!user.isEmailVerified) {
          // Dismiss the loading dialog.
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          // Set state as "AuthStateNeedsVerification" which sends user to Verify Email View.
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          // Dismiss the loading dialog.
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          // Set state to "Logged In".
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        // Set state to "Log Out" and pass in the exception.
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    }));

    //
    // SEND EMAIL VERIFICATION EVENT: When user needs to verify their email.
    on<AuthEventSendEmailVerification>((event, emit) async {
      // Send email verificaton to the user.
      await provider.sendEmailVerification();
      // We are not changing state.
      emit(state);
    });

    //
    // FORGOT PASSWORD EVENT: When user wants to reset their password.
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: false,
        ));

        // Get user's email
        final email = event.email;

        // If ser just got to forgot-password screen.
        if (email == null) {
          // Don't do anything.
          return;
        }

        // Else if user actually wants to reset their password and have provided a valid email...
        // Show Loading page.
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ));

        // For when exception might be thrown during sending password reset email.
        Exception? exception;
        // To indicate whether password reset email was sent or not.
        bool hasSentEmail;

        // Try to send user password reset email.
        try {
          // Send password reset email to user's email.
          await provider.sendPasswordReset(toEmail: email);
          hasSentEmail = true;
          exception = null;
        } on Exception catch (e) {
          hasSentEmail = false;
          exception = e;
        }

        // Dismiss loading page.
        emit(AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: hasSentEmail,
          isLoading: false,
        ));
      },
    );

    //
    // LOG OUT EVENT: When the user wants to log out.
    on<AuthEventLogOut>(((event, emit) async {
      try {
        // derail from tutorial {
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        // }
        // Log user out using our auth provider.
        await provider.logOut();
        // derail from tutorial {
        // Set state to "Logged Out" and dismiss loading dialog.
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        // }
      } on Exception catch (e) {
        // Set state to "Logged Out" and show exception.
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    }));
  }
}
