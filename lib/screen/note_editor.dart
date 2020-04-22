import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/styles.dart';
import 'package:note_app/widget/color_picker.dart';
import 'package:note_app/widget/note_actions.dart';
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

class _NoteEditorState extends State<NoteEditor> with CommandHandler {
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
  Color get _noteColor => _note?.color ?? kDefaultNoteColor;
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

    return ChangeNotifierProvider.value(
      value: _note,
      child: Consumer<Note>(
        builder: (_, __, ___) => Hero(
          tag: 'NoteItem${_note.id}',
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: _noteColor,
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                    elevation: 0,
                  ),
              scaffoldBackgroundColor: _noteColor,
              bottomAppBarColor: _noteColor,
            ),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: _noteColor,
                systemNavigationBarColor: _noteColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  actions: _buildTopActions(context, uid),
                  bottom: const PreferredSize(
                    child: SizedBox(),
                    preferredSize: Size(0, 24),
                  ),
                ),
                body: _buildBody(context, uid),
                bottomNavigationBar: _buildBottomAppBar(context),
              ),
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   key: _scaffoldKey,
    //   appBar: AppBar(
    //     actions: _buildTopActions(context, uid),
    //   ),
    //   body: _buildBody(context, uid),
    //   bottomNavigationBar: _buildBottomAppBar(context),
    // );
  }

  List<Widget> _buildTopActions(BuildContext context, String uid) => [
        if (_note.state != NoteState.deleted)
          IconButton(
            icon: Icon(
              _note.pinned == true ? AppIcons.pin : AppIcons.pin_outlined,
            ),
            tooltip: _note.pinned == true ? 'Unpin' : 'Pin',
            onPressed: () => _updateStateNote(
              uid,
              _note.pinned ? NoteState.unspecified : NoteState.pinned,
            ),
          ),
        if (_note.id != null && _note.state < NoteState.archived)
          IconButton(
            icon: Icon(AppIcons.archive_outlined),
            tooltip: 'Archive',
            onPressed: () => Navigator.pop(
              context,
              NoteStateUpdateCommand(
                id: _note.id,
                uid: uid,
                from: _note.state,
                to: NoteState.archived,
                dismiss: true,
              ),
            ),
          ),
        if (_note.state == NoteState.archived)
          IconButton(
            icon: Icon(AppIcons.unarchive_outlined),
            tooltip: 'Unarchived',
            onPressed: () => _updateStateNote(uid, NoteState.unspecified),
          ),
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

  Widget _buildBottomAppBar(BuildContext context) => BottomAppBar(
        child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(AppIcons.add_box),
                color: kIconTintLight,
                onPressed: _note.state.canEdit ? () {} : null,
              ),
              Text('Edited ${_note.strLastModified}'),
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: kIconTintLight,
                onPressed: () => _showNoteBottomSheet(context),
              ),
            ],
          ),
        ),
      );

  void _showNoteBottomSheet(BuildContext context) async {
    final command = await showModalBottomSheet(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _note,
        child: Consumer<Note>(
          builder: (_, note, __) => Container(
            color: note.color ?? kDefaultNoteColor,
            padding: const EdgeInsets.symmetric(vertical: 19),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NoteActions(),
                if (_note.state.canEdit) const SizedBox(height: 16),
                if (_note.state.canEdit) LinearColorPicker(),
              ],
            ),
          ),
        ),
      ),
    );

    if (command != null) {
      if (command.dismiss) {
        Navigator.pop(context, command);
      } else {
        processNoteCommand(_scaffoldKey.currentState, command);
      }
    }
  }

  Future<bool> _onPop(String uid) {
    debugPrint('_onPop');
    if (_isDirty && (_note.id != null || _note.isNotEmpty)) {
      _note
        ..modifiedAt = DateTime.now()
        ..saveToFireStore(uid);
    }
    return Future.value(true);
  }

  void _updateStateNote(String uid, NoteState state) {
    // new note, update locally
    if (_note.id == null) {
      _note.updateWith(state: state);
      return;
    }

    // otherwise, handles it in a undoable maner
    processNoteCommand(
      _scaffoldKey.currentState,
      NoteStateUpdateCommand(
        id: _note.id,
        uid: uid,
        from: _note.state,
        to: state,
      ),
    );
  }
}
