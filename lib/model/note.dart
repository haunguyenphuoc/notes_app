import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// State enum for a note
enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
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

  /// Whether this note is pinned
  bool get pinned => state == NoteState.pinned;

  /// Returns an numeric form of the state
  int get stateValue => (state ?? NoteState.unspecified).index;

  /// Check the note is not empty
  bool get isNotEmpty => title?.isEmpty == true || content?.isNotEmpty == true;

  /// Formatted last modified time
  String get strLastModified => DateFormat.MMMd().format(modifiedAt);

  /// Serializes this note into a JSON object
  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'color': color?.value,
        'state': stateValue,
        'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
        'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

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
