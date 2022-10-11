//// (4) Allocates each functionality of the AuthProvider based on the Provider.
/// Eg. If AuthProvider is Apple, is relays it to apple_auth_provider to handle
/// the of authentication. AuthService (in this case) does the exact same job as
/// the "AuthProvider". However later itcan have other services and more logic if needed.

import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  // Initiates AuthService for Firebase. So in other files you can easy use it by
  // typing Authservice.firebase(), and you will get access to all FirebaseAuthProvider
  // functionality through the AuthService.
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  // Delegate initialize() function to the provider.
  Future<void> initialize() => provider.initialize();
}
