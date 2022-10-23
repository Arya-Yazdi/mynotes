//// (3) Handles firebase authentication.

import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

// Function which handles user authentication using firebaseAuth.
class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      // Registed user using firebase.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get current user.
      final user = currentUser;
      // Make sure user was successfully created (stored in firebase's database)
      if (user != null) {
        // Return user if user is successfully created (logged into firebaseAuth).
        return user;
      } else {
        // Else throw a "user not logged in" exception.
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        // Catch any other FirebaseAuthException (that is not specified above).
        throw GenericAuthException();
      }
    } catch (_) {
      // Catch any other exceptions that may occur.
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    // Get user from FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;
    // If there is a user...
    if (user != null) {
      // Create the user using our "AuthUser" constructor
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get current user.
      final user = currentUser;
      // Make sure user was successfully created (stored in firebase's database)
      if (user != null) {
        // Return user if user is successfully created (logged into firebaseAuth).
        return user;
      } else {
        // Else throw a "user not logged in" exception.
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        // Catch any other FirebaseAuthException (that is not specified above).
        throw GenericAuthException();
      }
    } catch (_) {
      // Catch any other exceptions that may occur.
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Sign user out if user is not null.
      await FirebaseAuth.instance.signOut();
    } else {
      // Throw "User not logged in" exception if user is null.
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // Get current user from FirebaseAuth.
    // We cannot use user = currentUser as we need to use "sendEmailVerification()" and
    // that comes from FirebaseAuth and not from our "AuthUser" constructor implementation.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Send an email verification to the user.
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  // Function which initializes Firebase for our application.
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  // Function which sends user an email so they can reset their password if forgotten.
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }
}
