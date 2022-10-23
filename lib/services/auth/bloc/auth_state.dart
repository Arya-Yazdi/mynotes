// (1) Bloc states: Defining different states related to user authentication. (Defining Outputs of the Auth bloc)

import 'package:flutter/foundation.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

// Create a generic "AuthState" class. (aka Super class which will contain all states)
@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment...',
  });
}

// State for when firebase/application has not yet been initialized (so we can display loading screen etc.).
class AuthStateUninitialized extends AuthState {
  // Construtor. Set the isLoading parameter (which is inherited from the super class) to the "isLoading" bool
  // which is expected to be provided when the function is called.
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

// State for when we are registering a user.
class AuthStateRegistering extends AuthState {
  final Exception? exception;
  // Construtor. Set the isLoading parameter (which is inherited from the super class) to the "isLoading" bool
  // which is expected to be provided when the function is called.
  const AuthStateRegistering({
    required bool isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

// State for when user is logged in.
class AuthStateLoggedIn extends AuthState {
  // Declare a variable named "user" which is of type AuthUser.
  final AuthUser user;
  // Construtor. Set the isLoading parameter (which is inherited from the super class) to the "isLoading" bool
  // which is expected to be provided when the function is called.
  const AuthStateLoggedIn({required this.user, required bool isLoading})
      : super(isLoading: isLoading);
}

// State for when user needs to verify their email first.
class AuthStateNeedsVerification extends AuthState {
  // Construtor. Set the isLoading parameter (which is inherited from the super class) to the "isLoading" bool
  // which is expected to be provided when the function is called.
  const AuthStateNeedsVerification({required bool isLoading})
      : super(isLoading: isLoading);
}

// State for when user forgot their password and needs to resest it.
class AuthStateForgotPassword extends AuthState {
  // For when exception might be thrown during sending password reset email.
  final Exception? exception;
  // To indicate whether password reset email was sent or not.
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading,
  }) : super(isLoading: isLoading);
}

// State for when user is logged out.
// "with EquatableMixin" : A mixin that helps implement equality without needing to explicitly override [operator ==] and [hashCode].
// If we don't do this, when we compare "AuthStateLoggedOut" with another "AuthStateLoggedOut",
//it will always return true as their are the same class.
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  // Exception arising when user is logged out.
  final Exception? exception;
  // Construtor. Set the isLoading parameter (which is inherited from the super class) to the "isLoading" bool
  // which is expected to be provided when the function is called.
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingtext,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingtext,
        );

  // NOTE: Need below code because of "with EquatableMixin".
  @override
  // Take these two properties (exception & isLoading) into acount when computing equality "==" in
  // the instances of "AuthStateLoggedOut".
  List<Object?> get props => [exception, isLoading];
}
