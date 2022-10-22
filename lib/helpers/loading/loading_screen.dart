// Function which displays the loading screen (an overlay).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  // Make our "LoadingScreen" a singleton.
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;

  // Keep ahold of our loading screeen controller.
  LoadingScreenController? controller;

  //
  // Function which shows overlay.
  void show({
    required BuildContext context,
    required String text,
  }) {
    // final updateWasSucessfull = controller?.update(text) ?? false;
    if (controller?.update(text) ?? false) {
      // Return if we could successfully update the controller's text.
      return;
    } else {
      // Create overlay if there is no overlay already present on the screen.
      controller = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  //
  // Function which hides overlay.
  void hide() {
    controller?.close();
    controller = null;
  }

  //
  // Function which handles logic of showing and hiding of overlay.
  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    // Define a stream controller to keep track of the text we provide.
    final _text = StreamController<String>();

    // Add string to stream controller.
    _text.add(text);

    // Keeps track of different overlays to be displayed (like a stack)
    final state = Overlay.of(context);

    // Overlay doesnt have pre-set size so you have to tell it how big it should be.
    // Extract the available size that our overlay can have on the screen.
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Create an overlay which will display the text provided to the "_text" stream controller.
    final overlay = OverlayEntry(
      builder: (context) {
        // Need to return a Material/Scaffold so there is automatic styling.
        return Material(
          // Set entire background color to black with opacity of 150 out of 255.
          color: Colors.black.withAlpha(150),
          // Make element to be displayed center.
          child: Center(
            // All elements are in a container.
            child: Container(
              // Set container's maximum/minimum width and height (Essentially creating margins)
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              // Add white border to container.
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              // Container's child:
              // create padding for content to be placed inside the container.
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Allow user to scroll within container if content are too much for given max height.
                child: SingleChildScrollView(
                  child: Column(
                    // Make column as small as possible.
                    mainAxisSize: MainAxisSize.min,
                    // Place column's children at the center of the column.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Display a circular progress indicator.
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      // Display text from stream controller.
                      StreamBuilder(
                        stream: _text.stream,
                        builder: (context, snapshot) {
                          // If there is a text in our "_text" stream controller
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Add our overlay to the overlay stack for it to be displayed.
    state?.insert(overlay);

    return LoadingScreenController(
      close: () {
        // Close the text stream.
        _text.close();
        // Remove the overlay.
        overlay.remove();
        // Return true to indicate that the overlay was dismissed/closed.
        return true;
      },
      update: (text) {
        // Add text to be displayed to our _text stream controller.
        _text.add(text);
        return true;
      },
    );
  }
}
