// Function which asks users if they are sure they want to delete their note.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this note?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
    // If user takes any other action instead of pressing on "Cancel" or "Delete" button, return false.
  ).then((value) => value ?? false);
}
