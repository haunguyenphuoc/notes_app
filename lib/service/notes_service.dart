import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/styles.dart';
import 'package:collection_ext/iterables.dart';

/// Add note related methods to [QuerySnapshot]
extension NoteQuery on QuerySnapshot {
  List<Note> toNotes() => documents.map((d) => d.toNote()).nonNull.asList();
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
