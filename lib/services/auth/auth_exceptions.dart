////// Creating classes to handle exceptions (so that main UI doesn't have
////// to directly interact with FirebaseAuthExceptions for security reasons)

//// Login Exceptions.
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//// Register Exceptions.
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//// Generic Exceptions.
class GenericAuthException implements Exception {}

// Used when user = null
class UserNotLoggedInAuthException implements Exception {}
