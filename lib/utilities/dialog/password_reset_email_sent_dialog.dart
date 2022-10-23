// Dialog displayed to notify user than an email was sent so they can reset their password.

import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content: 'We have sent an email so you can reset your password!',
    optionsBuilder: () => {'OK': null},
  );
}
