import 'package:flutter/material.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/styles.dart';
import 'package:provider/provider.dart';
import 'package:note_app/service/notes_service.dart';

class NoteEditor extends StatefulWidget {
  ///Create a [NoteEditor]
  /// provides an existed [noted] in edit mode, or `null` to create a new one
  const NoteEditor({Key key, this.note}) : super(key: key);
  final Note note;

  @override
  _NoteEditorState createState() => _NoteEditorState(note);
}

class _NoteEditorState extends State<NoteEditor> {
  /// Create a state for [NoteEditor], with an optional [note] being edted
  /// otherwise a new one be created
  _NoteEditorState(Note note)
      : this._note = note ?? Note(),
        this._originNote = note?.copy() ?? Note(),
        this._titleTextController = TextEditingController(text: note?.title),
        this._contentTextController =
            TextEditingController(text: note?.content);

  /// The note in editing
  final Note _note;

  /// The origin copy before editing
  final Note _originNote;
  final TextEditingController _titleTextController;
  final TextEditingController _contentTextController;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// If the note is modified
  bool get _isDirty => _note != _originNote;

  @override
  void initState() {
    super.initState();
    _titleTextController
        .addListener(() => {_note.title = _titleTextController.text});
    _contentTextController
        .addListener(() => {_note.content = _contentTextController.text});
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
      key: _scaffoldKey,
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
    if (_isDirty && (_note.id != null || _note.isNotEmpty)) {
      _note
        ..modifiedAt = DateTime.now()
        ..saveToFireStore(uid);
    }
    return Future.value(true);
  }
}
