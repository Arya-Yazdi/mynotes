// // Loading dialog displayed to the user while application is making an API call.

// import 'package:flutter/material.dart';

// // Lets our dialog to return a function. Function which the caller can call to dismiss loading dialog.
// typedef CloseDialog = void Function();

// // Function whcih displays a loading dialog. Function will return a function (CloseDialog) to the caller
// // which the caller can call to dismiss the loadin dialog.
// // Function which asks users if they are sure they want to delete their note.
// CloseDialog showLoadingDialog({
//   required BuildContext context,
//   required String text,
// }) {
//   // Define the Loading Dialog.
//   final dialog = AlertDialog(
//     content: Column(
//       // Column to take as little space as possible.
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const CircularProgressIndicator(),
//         // SizeBox() is used to creating spacing (spacing between elements in a column).
//         const SizedBox(height: 10.0),
//         Text(text),
//       ],
//     ),
//   );

//   // Display the loading dialog.
//   showDialog(
//     context: context,
//     // Don't allow user to dismiss dialog by tapping outside of the dialog.
//     barrierDismissible: false,
//     builder: (context) => dialog,
//   );

//   // We are returning a function (CloseDialog). Upon it being called, dismiss the dialog (need to call CloseDialog())
//   return () {
//     Navigator.of(context).pop();
//   };
// }
