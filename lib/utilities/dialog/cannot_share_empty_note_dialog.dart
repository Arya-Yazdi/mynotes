// Function which displays error dialog to the user when they try to share a note which
// does not contain any text.

import 'package:flutter/material.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.sharing,
    content: context.loc.cannot_share_empty_note_prompt,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
