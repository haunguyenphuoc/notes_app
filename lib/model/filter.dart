import 'package:flutter/cupertino.dart';
import 'package:note_app/model/note.dart';

class NoteFilter extends ChangeNotifier {
  NoteState _noteState;

  /// The state of note to search.

  NoteState get noteState => _noteState;
  set noteState(NoteState value) {
    debugPrint('Note Filter - notifyListeners');
    if (value != null && value != _noteState) {
      _noteState = value;
      notifyListeners();
    }
  }

  /// Creates a [NoteFilter] object.

  NoteFilter([this._noteState = NoteState.unspecified]);
}
