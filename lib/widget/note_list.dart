import 'package:flutter/material.dart';
import 'package:note_app/model/note.dart';
import 'package:collection_ext/iterables.dart';
import 'package:note_app/widget/note_item.dart';

class NoteList extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note) onTap;

  const NoteList({Key key, @required this.notes, this.onTap}) : super(key: key);

  static NoteList create(
          {Key key, @required List<Note> notes, void Function(Note) onTap}) =>
      NoteList(
        key: key,
        notes: notes,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            notes
                .flatMapIndexed((i, note) => <Widget>[
                      InkWell(
                        onTap: () => onTap?.call(note),
                        child: NoteItem(note: note),
                      ),
                      if (i < notes.length - 1) const SizedBox(height: 10),
                    ])
                .asList(),
          ),
        ),
      );
}
