import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

// Create Exception for when a function is called and the mock auth provider has not been initialized yet.
class NotInitializedException implements Exception {}

// Main function used to writing tests.
void main() {
  // Create a group to group related tests together.

  group("Mock Authentication", () {
    // Create an instance of out mock auth provider.
    final provider = MockAuthProvider();

    // Test which ensures mock auth provider is not initialized.
    test("1. Should not be initialized to begin with", () {
      // Ensure provider.isInitialized is set to false.
      expect(provider.isInitialized, false);
    });

    test(
      "2. Cannot log out if not initialized",
      () {
        // Ensure provider.logOut() throws a "NotInitializedException" Exception.
        expect(provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()));
      },
    );

    // Test which ensures auth provider can be initialized.
    test("3. Should be able to be initialized", () async {
      // Initialize provider.
      await provider.initialize();

      expect(provider.isInitialized, true);
    });

    test(
      "4. User should be null after initialization",
      () {
        expect(provider.currentUser, null);
      },
    );

    test(
      "5. Should be able to initialize in less than 2 seconds",
      () async {
        // initialize provider.
        await provider.initialize();

        // Expect isInitialized is set to true (provider is initialized)
        expect(provider.isInitialized, true);
      },
      // Ensure initialize() function completed in less than 2 seconds.
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // Testing createUser() and logIN() function.
    test(
      "6. Create user should deligate to logIn function",
      () async {
        // Create a user with a bad password.
        final badPasswordUser =
            provider.createUser(email: "any@email.com", password: "foobar");

        // Ensure "WrongPasswordAuthException" Exception is thrown.
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        // Create a user with a bad email.
        final badEmailUser =
            provider.createUser(email: "foo@bar.com", password: "anyPassword");

        // Ensure "UserNotFoundAuthException" Exception is thrown.
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));

        // Create a user who in theory should have no issues with their email and password.
        final user = await provider.createUser(
            email: "anyEmail@email.com", password: "anything");

        // Ensure user is successfully logged in.
        expect(provider.currentUser, user);

        // Ensure user's "isEmailVerified" is set to false.
        expect(user.isEmailVerified, false);
      },
    );

    // Testing sendEmailVerification() function.
    test(
      "7. Logged in user should be able to get email verified",
      () async {
        // Call sendEmailVerification() function.
        await provider.sendEmailVerification();

        // Get current user from provider.
        final user = provider.currentUser;

        // Ensure user is not null.
        expect(user, isNotNull);

        expect(user!.isEmailVerified, true);
      },
    );

    test(
      "8. Should be able to log out and log in again",
      () async {
        // Log user out.
        await provider.logOut();

        // Log user in.
        await provider.logIn(email: "email@email.com", password: "password");

        // Get current user from provider.
        final user = provider.currentUser;

        // Ensure user is not null (logged in).
        expect(user, isNotNull);
      },
    );
  });
}

// Create a mock Auth Provider to use when running tests.
class MockAuthProvider implements AuthProvider {
  // Create a variable caleld _user of type AuthUser
  AuthUser? _user;

  // Create a variable to track wether our mock Auth Provider is initialized or not.
  var _isInitialized = false;

  // Getter which returns _isInitialized variable.
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    // Throw exception if mock auth provider is not initialized.
    if (!isInitialized) throw NotInitializedException();

    // Delay code execution (to make it realistic as it's "making an API call").
    await Future.delayed(const Duration(seconds: 1));

    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    // Delay code execution (to make it realistic as it's "initializing").
    await Future.delayed(const Duration(seconds: 1));

    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    // Throw exception if mock auth provider is not initialized.
    if (!isInitialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw UserNotFoundAuthException();

    if (password == "foobar") throw WrongPasswordAuthException();

    // Create an instance of AuthUser.
    const user = AuthUser(
      id: 'id_number',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );

    // Set _user variable to user we just created.
    _user = user;

    // Return the value of the Future and not its instance (the Future instance)
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    // Throw exception if mock auth provider is not initialized.
    if (!isInitialized) throw NotInitializedException();

    // Ensure user is already logged in.
    if (_user == null) throw UserNotFoundAuthException();

    // Delay code execution.
    await Future.delayed(const Duration(seconds: 1));

    // Make user "Logged out".
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Throw exception if mock auth provider is not initialized.
    if (!isInitialized) throw NotInitializedException();

    // Make sure user is logged in.
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();

    // isEmailVerified for "user" is read only therefore we need to fake create another user and set
    // the new users "isEmailVerified" to true and pretent that the "newUser" is actually our main "user".
    const newUser = AuthUser(
      id: 'id_number',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );

    // Set our actual/current user to the newUser.
    _user = newUser;
  }
}
