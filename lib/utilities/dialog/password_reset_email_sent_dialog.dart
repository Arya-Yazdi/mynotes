// Dialog displayed to notify user than an email was sent so they can reset their password.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';
import 'package:mynotes/extentions/buildcontext/loc.dart';

Future<void> showPasswordResetSentDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.password_reset,
    content: context.loc.password_reset_dialog_prompt,
    optionsBuilder: () => {context.loc.ok: null},
  );
}
