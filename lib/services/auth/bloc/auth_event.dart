// (2) Bloc events: Defining different events related to user authentication. (Defining Inputs to the Auth bloc)
import 'package:flutter/foundation.dart' show immutable;

// Create a generic "AuthEvent" class. (aka Super class which will contain all states)
@immutable
abstract class AuthEvent {
  const AuthEvent();
}

// Event for when we are initializing firebase.
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// Event for when user wants to log in.
class AuthEventLogIn extends AuthEvent {
  // For user's email.
  final String email;
  // For user's password.
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

// Event for when user is logged in but needs to verify their email first.
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

// Event for when user wants to register.
class AuthEventRegister extends AuthEvent {
  // For user's email.
  final String email;
  // For user's password.
  final String password;
  const AuthEventRegister(this.email, this.password);
}

// Event for when user is in loggin page but wants to register.
class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

// Event for when user wants to log out.
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}
