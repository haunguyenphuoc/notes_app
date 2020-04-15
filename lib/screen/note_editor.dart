import 'package:flutter/material.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/styles.dart';
import 'package:provider/provider.dart';
import 'package:note_app/service/notes_service.dart';

class NoteEditor extends StatefulWidget {
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  /// The note in editing
  final Note _note = Note();

  final TextEditingController _titleTextController =
      TextEditingController(text: '');
  final TextEditingController _contentTextController =
      TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _titleTextController
        .addListener(() => {_note.title = _titleTextController.text});
    _contentTextController
        .addListener(() => {_note.content = _titleTextController.text});
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<CurrentUser>(context).data.uid;
    debugPrint('uid: $uid');
    return Scaffold(
      appBar: AppBar(
        actions: _buildTopActions(context, uid),
      ),
      body: _buildBody(context, uid),
    );
  }

  List<Widget> _buildTopActions(BuildContext context, String uid) => [
        IconButton(
          icon: Icon(AppIcons.pin),
          tooltip: 'Pin',
          onPressed: () => {},
        ),
        IconButton(
          icon: Icon(AppIcons.archive_outlined),
          tooltip: 'Archive',
          onPressed: () => {},
        )
      ];

  Widget _buildBody(BuildContext context, String uid) => DefaultTextStyle(
        style: kNoteTextLargeLight,
        child: WillPopScope(
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: _buildNoteDetail(),
            ),
          ),
          onWillPop: () => _onPop(uid),
        ),
      );

  Widget _buildNoteDetail() => Column(
        children: <Widget>[
          TextField(
            controller: _titleTextController,
            style: kNoteTitleLight,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              counter: const SizedBox(),
            ),
            maxLength: 1024,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(
            height: 14,
          ),
          TextField(
            controller: _contentTextController,
            style: kNoteTextLargeLight,
            decoration: const InputDecoration.collapsed(
              hintText: 'Note',
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      );

  Future<bool> _onPop(String uid) {
    debugPrint('_onPop');
    if ((_note.id != null || _note.isNotEmpty)) {
      debugPrint('saveToFireStore + uid: $uid');
      _note
        ..modifiedAt = DateTime.now()
        ..saveToFireStore(uid);
    }
    return Future.value(true);
  }
}
