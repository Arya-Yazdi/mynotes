// GENERIC layout/skeleton to be used when you need to display a dialog.

// returns <T?> (T being a boolean value). It is optional (?) as user may not directly click on the
// buttons which are on the dialog that is displayed therefore it may return null.

import 'package:flutter/material.dart';

// Map which maps a String (text written on button for user to see) to the value of that button
// (T). as "T" is a boolean (just because we say it is), A button will either be a "true" or a "false". We are
// essentially mapping the text on that button to a true/false. That text on button can be literary anything.
// When calling showGenericDialog(), for its "optionsBuilder:" you need to call a function which returns
// a map of "button texts" to "return values". Example:
// return showGenericDialog(
//   context: context, title: 'Are you sure?', content: text, optionsBuilder: () => {'YES': true, 'NO': false},
// );
typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// Function which shows the related dialog.
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  // Title of dialog.
  required String title,
  // Content of dialog.
  required String content,
  // Buttons of dialog (button's text and it's return value)
  required DialogOptionBuilder optionsBuilder,
}) {
  // Get map of buttons (button's text and it's return value)
  final options = optionsBuilder();
  // Show the Dialog.
  return showDialog<T>(
    context: context,
    builder: (context) {
      // Contents of that dialog should be...
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        // Get the key from our "options" map (key is Text of button)
        actions: options.keys.map((optionTitle) {
          // Get the value/return value of the button associated with the button text.
          final value = options[optionTitle];
          return TextButton(
              // When user interacts with screen...
              onPressed: () {
                // If the button on dialog is pressed...
                if (value != null) {
                  // Dismiss the dialog and return the buttons value.
                  Navigator.of(context).pop(value);
                } else {
                  // Dismiss dialog if user doesn't press any buttons on the dialog.
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionTitle));
        }).toList(),
      );
    },
  );
}
