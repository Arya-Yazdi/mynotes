//// (1) Creating class to abstract user away (so that main UI doesn't have
//// to directly interact with FirebaseAuth for security reasons)

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
// Constructor which stores wether the user's email is verified or not.
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  // Create a factory constructor.
  // Get user from FirebaseAuth and call our own "AuthUser" constructor to create a copy of that user.
  // Get user's email verification state and set the "isEmailVerified" variable for the user's instance.
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
