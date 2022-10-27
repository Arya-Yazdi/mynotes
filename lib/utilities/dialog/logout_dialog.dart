// Function which asks users if they are sure they want to log out of their account.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

Future<bool> showLogOutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
    // If user takes any other action instead of pressing on "Cancel" or "Log out" button, return false.
  ).then((value) => value ?? false);
}
