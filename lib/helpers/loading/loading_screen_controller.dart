// Controller for our Loading Screen. So we can close the loading screen and update its content.

import 'package:flutter/foundation.dart' show immutable;

// Typedef function which returns a bool indicating whether overlay was closed or not after being displayed.
typedef CloseLoadingScreen = bool Function();

// Typedef function which returns bool indicating if we are able to update the loading screen text.
// Takes in a 'text' to display on the loading screen.
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({required this.close, required this.update});
}
