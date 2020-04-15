import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/model/note.dart';

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
