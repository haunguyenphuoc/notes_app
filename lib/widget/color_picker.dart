import 'package:flutter/material.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/styles.dart';
import 'package:provider/provider.dart';
import 'package:collection_ext/iterables.dart';

/// Returns color of the note, fallbacks to the default color.
Color _currColor(Note note) => note?.color ?? kDefaultNoteColor;

class LinearColorPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Note note = Provider.of<Note>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kNoteColors
            .flatMapIndexed((i, color) => [
                  if (i == 0) const SizedBox(width: 17),
                  InkWell(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: kColorPickerBorderColor),
                      ),
                      child: color == _currColor(note)
                          ? const Icon(Icons.check,
                              color: kColorPickerBorderColor)
                          : null,
                    ),
                    onTap: () {
                      if (color != _currColor(note)) {
                        note.updateWith(color: color);
                      }
                    },
                  ),
                  SizedBox(width: i == kNoteColors.length - 1 ? 17 : 20),
                ])
            .asList(),
      ),
    );
  }
}
