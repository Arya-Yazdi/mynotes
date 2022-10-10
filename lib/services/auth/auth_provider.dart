//// Creates a base for using different Auth providers (such as google, apple, facebook, github)
//// You need to implement the actual handling of each auth provider seperately.

import 'package:mynotes/services/auth/auth_user.dart';

// You cannot create an instance of an abract class (it is only used for inheritance).
abstract class AuthProvider {
  // (Defining a getter) Get the current user no matter the auth provider (can be from any auth provider).
  // ? is used as AuthUser might return null if there is no user.
  AuthUser? get currentUser;

  // Function which Log a user in using their email/id and password.
  // Note: Future returns an "AuthUser"
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  // Function which Create a user in using their email/id and password.
  // Note: Future returns an "AuthUser"
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  // Function which logs user out.
  Future<void> logOut();

  // Function which sends an email verification to the user.
  Future<void> sendEmailVerification();
}
