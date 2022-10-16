// Function which asks users if they are sure they want to log out of their account.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showLogOutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out of MyNotes?',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
    // If user takes any other action instead of pressing on "Cancel" or "Log out" button, return false.
  ).then((value) => value ?? false);
}
