// Add extension to "BuildContext" so we are able to extract an argument of any type from a build context.
import 'package:flutter/material.dart' show BuildContext, ModalRoute;

// Add an extension to dart's "BuildContext" class
extension GetArgument on BuildContext {
  // Optionally sreturn a value of type T.
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      // Get the arguments from BuildContext.
      final args = modalRoute.settings.arguments;
      // If BuildContext returned an argument/arguments and it is of type "T",
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
