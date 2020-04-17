import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:note_app/service/notes_service.dart';

/// State enum for a note
enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
}

/// Add properties/methods to [NoteState]
extension MoteStateX on NoteState {
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archived:
        return 'Archived notes appear here';
      case NoteState.deleted:
        return 'Notes in trash appear here';
      default:
        return 'Notes you add appear here';
    }
  }
}

class Note extends ChangeNotifier {
  final String id;
  String title;
  String content;
  Color color;
  NoteState state;
  final DateTime createdAt;
  DateTime modifiedAt;

  /// Instantiates a [Note]
  Note({
    this.id,
    this.title,
    this.content,
    this.color,
    this.state,
    DateTime createdAt,
    DateTime modifiedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now();

  static List<Note> fromQuery(QuerySnapshot snapshot) =>
      snapshot != null ? snapshot.toNotes() : [];

  /// Whether this note is pinned
  bool get pinned => state == NoteState.pinned;

  /// Returns an numeric form of the state
  int get stateValue => (state ?? NoteState.unspecified).index;

  /// Check the note is not empty
  bool get isNotEmpty => title?.isEmpty == true || content?.isNotEmpty == true;

  /// Formatted last modified time
  String get strLastModified => DateFormat.MMMd().format(modifiedAt);

  /// Update this note with another one.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`, otherwise, the value of `modified`
  /// will also be copied form [other].

  void update(Note other, {bool updateTimestamp = true}) {
    title = other.title;
    content = other.content;
    color = other.color;
    state = other.state;

    if (updateTimestamp || other.modifiedAt == null) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other.modifiedAt;
    }
    notifyListeners();
  }

  /// Serializes this note into a JSON object
  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'color': color?.value,
        'state': stateValue,
        'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
        'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  /// Mkae a copy of this note
  ///
  /// If [updateTimestamp] is `true`, the defaults is `false`
  /// timestamps both of `createdAt` & `modifiedAt` will be updated to `DateTime.now()`
  /// or otherwise be indentical with this note.
  Note copy({bool updateTimestamp = false}) => Note(
        id: id,
        createdAt:
            (updateTimestamp || createdAt == null) ? DateTime.now() : createdAt,
      )..update(this, updateTimestamp: updateTimestamp);

  /// compare note
  @override
  bool operator ==(other) =>
      other is Note &&
      (other.id ?? '') == (id ?? '') &&
      (other.title ?? '') == (title ?? '') &&
      (other.content ?? '') == (content ?? '') &&
      (other.state ?? '') == (state ?? '') &&
      (other.color ?? '') == (color ?? '');

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;
}
