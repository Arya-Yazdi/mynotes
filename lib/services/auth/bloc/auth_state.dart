// (1) Bloc states: Defining different states related to user authentication. (Defining Outputs of the Auth bloc)

import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

// Create a generic "AuthState" class. (aka Super class which will contain all states)
@immutable
abstract class AuthState {
  const AuthState();
}

// State for when firebase/application has not yet been initialized (so we can display loading screen etc.).
class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

// State for when we are registering a user.
class AuthStateRegistering extends AuthState {
  final Exception exception;
  const AuthStateRegistering(this.exception);
}

// State for when user is logged in.
class AuthStateLoggedIn extends AuthState {
  // Declare a variable named "user" which is of type AuthUser.
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

// State for when user needs to verify their email first.
class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

// State for when user is logged out.
// "with EquatableMixin" : A mixin that helps implement equality without needing to explicitly override [operator ==] and [hashCode].
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  // Exception arising when user is logged out.
  final Exception? exception;
  // While waiting for user to be registered/logged in.
  final bool isLoading;
  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
  });

  // Need below come because of "with EquatableMixin".
  @override
  // Take these two properties (exception & isLoading) into acount when computing equality "==" in
  // the instances of "AuthStateLoggedOut".
  List<Object?> get props => [exception, isLoading];
}
