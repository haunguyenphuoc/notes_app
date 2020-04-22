import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/filter.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/styles.dart';
import 'package:note_app/widget/drawer_filter.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<NoteFilter>(
        builder: (context, filter, _) => Drawer(
          child: Column(
            children: <Widget>[
              _drawerHeader(context),
              const SizedBox(height: 25),
              DrawerFilterItem(
                icon: AppIcons.thumbtack,
                title: 'Notes',
                isChecked: filter.noteState == NoteState.unspecified,
                onTap: () {
                  filter.noteState = NoteState.unspecified;
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              DrawerFilterItem(
                icon: AppIcons.archive_outlined,
                title: 'Archived',
                isChecked: filter.noteState == NoteState.archived,
                onTap: () {
                  filter.noteState = NoteState.archived;
                  Navigator.pop(context);
                },
              ),
              DrawerFilterItem(
                icon: AppIcons.delete_outline,
                title: 'Trash',
                isChecked: filter.noteState == NoteState.deleted,
                onTap: () {
                  filter.noteState = NoteState.deleted;
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              DrawerFilterItem(
                icon: AppIcons.delete_outline,
                title: 'Log out',
                isChecked: false,
                onTap: () {
                  //Navigator.pop(context);
                  _signOut(context);
                },
              ),
            ],
          ),
        ),
      );

  Widget _drawerHeader(BuildContext context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: kHintTextColorLight,
                fontSize: 26,
                fontWeight: FontWeights.light,
              ),
              children: [
                const TextSpan(
                  text: 'Flt',
                  style: TextStyle(
                    color: kAccentColorLight,
                    fontWeight: FontWeights.medium,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const TextSpan(text: 'Keep'),
              ],
            ),
          ),
        ),
      );

  void _signOut(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure to sign out the current account?'),
        actions: <Widget>[
          FlatButton(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (yes) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  }
}
