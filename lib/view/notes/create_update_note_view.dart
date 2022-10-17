// View shown when users click the "+" icon from notes_view to create and type their new note.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  // Create a variable called "_note" which is of type DatabaseNote.
  DatabaseNote? _note;

  // Create a variable of type NoteService and name the variable  "_noteService".
  late final NoteService _noteService;

  // Declare controller which keeps track of user's text as they are typing their note.
  late final TextEditingController _textController;

  // initState() is always called once at the very beginning (when view is called?)
  @override
  void initState() {
    // Create an instance of NoteService.
    _noteService = NoteService();

    // Create an intance of TextEditingController.
    _textController = TextEditingController();

    super.initState();
  }

  // Function which listens to changes in the note and updated the note in our database.
  void _textControllerListener() async {
    // Get created note
    final note = _note;

    // If no note was created...
    if (note == null) {
      return;
    }

    // Get most recent text from our _textController.
    final text = _textController.text;

    // Update note with most recent text in our database.
    await _noteService.updateNote(note: note, text: text);
  }

  // Function which ???
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  // Function which creates an empty note (when user's press the "+" icon) so user can type their text into it.
  // Function is also called if the user wants to update their note.
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    // Get argument if Widget passed an argument. (The note text when user taps on it to update/edit)
    final widgetNote = context.getArgument<DatabaseNote>();

    // If user tapped on a note in order to edit it...
    if (widgetNote != null) {
      _note = widgetNote;
      // Set "_textController" text as text of note to be edited.
      _textController.text = widgetNote.text;

      return widgetNote;
    }

    final existingNote = _note;
    // This if statement ensures the empty note is created only once.
    if (existingNote != null) {
      // Return that note.
      return existingNote;
    }
    // Get current user from firebase.
    final currentUser = AuthService.firebase().currentUser!;

    // Get current user's email
    final email = currentUser.email;

    // Get current user stored in our database.
    final owner = await _noteService.getUser(email: email);

    // Create new note.
    final newNote = await _noteService.createNote(owner: owner);

    _note = newNote;

    return newNote;
  }

  // Function which deleted user note if they dispose the page and they have written no text.
  void _deleteNoteIfTextIsEmpty() {
    // Get the note which was created.
    final note = _note;

    // If there was a note created however there were no changes made to it...
    if (_textController.text.isEmpty && note != null) {
      // Delete that note.
      _noteService.deleteNote(id: note.id);
    }
  }

  // Function which saves note if its text is not empty.
  void _saveNoteIfTextNotEmpty() async {
    // Get the note which was created.
    final note = _note;

    // Get updated text from our textcontroller.
    final text = _textController.text;

    // If a note is created and it's text is not empty.
    if (note != null && text.isNotEmpty) {
      // Update the note in our database
      await _noteService.updateNote(note: note, text: text);
    }
  }

  // dispose() is always called once at the very end (when view is exited?)
  @override
  void dispose() {
    // Delete created note if it contains no text.
    _deleteNoteIfTextIsEmpty();

    // Save note if it does contain text.
    _saveNoteIfTextNotEmpty();

    // Discard contents of _textController (as we no longer need to use its content AKA the text changes)
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // Start Listening to changes in the text (as user starts typing)
              _setupTextControllerListener();

              // Return TextField so user can type their text.
              return TextField(
                // Send text changes to our "_textController"
                controller: _textController,

                // Allow user to type as many lines as they need.
                // (flutter TextField are only 1 line as default)
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration:
                    const InputDecoration(hintText: "What's on your mind?"),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
