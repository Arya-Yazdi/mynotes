// General function which takes in an error text and displays it as a dialog to the user.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  // Error message.
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occured!',
    content: text,
    optionsBuilder: () => {'OK': null},
  );
}
