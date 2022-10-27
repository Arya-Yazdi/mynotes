// Function which asks users if they are sure they want to delete their note.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.delete: true,
    },
    // If user takes any other action instead of pressing on "Cancel" or "Delete" button, return false.
  ).then((value) => value ?? false);
}
