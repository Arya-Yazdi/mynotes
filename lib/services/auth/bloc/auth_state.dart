// (1) Bloc states: Defining different states related to user authentication. (Defining Outputs of the Auth bloc)

import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

// Create a generic "AuthState" class. (aka Super class which will contain all states)
@immutable
abstract class AuthState {
  const AuthState();
}

// State for when firebase is being initialized. Or during/while we are making an API call which takes time.
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

// State for when user is logged in.
class AuthStateLoggedIn extends AuthState {
  // Declare a variable named "user" which is of type AuthUser.
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

// State for when there has been an exception when user is trying to log in.
class AuthStateLogInFailure extends AuthState {
  final Exception exception;
  const AuthStateLogInFailure(this.exception);
}

// State for when user needs to verify their email first.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// State for when user is logged out.
class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut();
}

// State for when there has been an exception when user is trying to log in.
class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}
