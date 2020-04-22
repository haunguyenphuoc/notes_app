import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/styles.dart';
import 'package:collection_ext/iterables.dart';

@immutable
abstract class NoteCommand {
  final String id;
  final String uid;

  /// whether this command should dismiss current screen.
  final bool dismiss;

  /// Defines an unable action to note, provide the note [id], and current user [uid]
  const NoteCommand({
    @required this.id,
    @required this.uid,
    this.dismiss = false,
  });

  /// Return [true] if this command is undoable
  bool get isUndoable => true;

  /// Return about result of the action
  String get message => '';

  /// Execute this command
  Future<void> execute();

  /// Undo this command
  Future<void> revert();
}

/// A [NoteCommand] to update state of the note
class NoteStateUpdateCommand extends NoteCommand {
  final NoteState to;
  final NoteState from;

  NoteStateUpdateCommand({
    @required String id,
    @required String uid,
    @required this.from,
    @required this.to,
    bool dismiss = false,
  }) : super(id: id, uid: uid, dismiss: dismiss);

  @override
  String get message {
    switch (to) {
      case NoteState.deleted:
        return 'Note move to trash';
      case NoteState.archived:
        return 'Note archived';
      case NoteState.pinned:
        return from == NoteState.archived ? 'Note pinned and archived' : '';
      default:
        switch (from) {
          case NoteState.archived:
            return 'Note unarchived';
          case NoteState.deleted:
            return 'Note restored';
          default:
            return '';
        }
    }
  }

  @override
  Future<void> execute() => updateNoteState(to, id, uid);

  @override
  Future<void> revert() => updateNoteState(from, id, uid);
}

/// Add note related methods to [QuerySnapshot]
extension NoteQuery on QuerySnapshot {
  List<Note> toNotes() => documents.map((d) => d.toNote()).nonNull.asList();
}

mixin CommandHandler<T extends StatefulWidget> on State<T> {
  /// Process this give [command]
  Future<void> processNoteCommand(
      ScaffoldState scaffoldState, NoteCommand command) async {
    if (command == null) {
      return;
    }
    await command.execute();
    final msg = command.message;
    debugPrint('message: $msg');
    if (mounted && msg?.isNotEmpty == true && command.isUndoable) {
      scaffoldState?.showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => command.revert(),
          ),
        ),
      );
    }
  }
}

extension NoteDocument on DocumentSnapshot {
  Note toNote() => exists
      ? Note(
          id: documentID,
          title: data['title'],
          content: data['content'],
          color: _parseColor(data['color']),
          state: NoteState.values[data['state'] ?? 0],
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
          modifiedAt:
              DateTime.fromMillisecondsSinceEpoch(data['modifiedAt'] ?? 0),
        )
      : null;
}

Color _parseColor(num colorInt) => Color(colorInt ?? kNoteColors.first.value);

extension NoteStore on Note {
  Future<dynamic> saveToFireStore(String uid) async {
    final col = notesCollection(uid);
    return id == null
        ? col.add(toJson())
        : col.document(id).updateData(toJson());
  }
}

/// Returns reference to the notes collection of the user [uid]
CollectionReference notesCollection(String uid) =>
    Firestore.instance.collection('notes-$uid');

DocumentReference noteDocument(String id, String uid) =>
    notesCollection(uid).document(id);

Future<void> updateNoteState(NoteState state, String id, String uid) =>
    updateNote({'state': state?.index ?? 0}, id, uid);

Future<void> updateNote(Map<String, dynamic> data, String id, String uid) =>
    noteDocument(id, uid).updateData(data);
