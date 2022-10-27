// General function which takes in an error text and displays it as a dialog to the user.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

Future<void> showErrorDialog(
  BuildContext context,
  // Error message.
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
