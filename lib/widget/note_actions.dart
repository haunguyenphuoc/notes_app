import 'package:flutter/material.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/service/notes_service.dart';
import 'package:note_app/styles.dart';
import 'package:provider/provider.dart';

class NoteActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final note = Provider.of<Note>(context);
    final state = note?.state;
    final id = note?.id;
    final uid = Provider.of<CurrentUser>(context)?.data?.uid;

    final textSytle = TextStyle(
      color: kHintTextColorLight,
      fontSize: 16,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (id != null && state < NoteState.archived)
          ListTile(
            leading: const Icon(AppIcons.archive_outlined),
            title: Text('Archive', style: textSytle),
            onTap: () => Navigator.pop(
              context,
              NoteStateUpdateCommand(
                id: id,
                uid: uid,
                from: state,
                to: NoteState.archived,
                dismiss: true,
              ),
            ),
          ),
        if (state == NoteState.archived)
          ListTile(
            leading: const Icon(AppIcons.unarchive_outlined),
            title: Text('Unarchive', style: textSytle),
            onTap: () => Navigator.pop(
              context,
              NoteStateUpdateCommand(
                id: id,
                uid: uid,
                from: state,
                to: NoteState.unspecified,
              ),
            ),
          ),
        if (id != null && state != NoteState.deleted)
          ListTile(
            leading: const Icon(AppIcons.delete_outline),
            title: Text('Delete', style: textSytle),
            onTap: () => Navigator.pop(
              context,
              NoteStateUpdateCommand(
                id: id,
                uid: uid,
                from: state,
                to: NoteState.deleted,
                dismiss: true,
              ),
            ),
          ),
        if (id != null && state == NoteState.deleted)
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text('Restore', style: textSytle),
            onTap: () => Navigator.pop(
              context,
              NoteStateUpdateCommand(
                id: id,
                uid: uid,
                from: state,
                to: NoteState.unspecified,
              ),
            ),
          ),
        ListTile(
          leading: const Icon(AppIcons.share_outlined),
          title: Text('Send', style: textSytle),
          onTap: () {},
        ),
      ],
    );
  }
}
