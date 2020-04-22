import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/icons.dart';
import 'package:note_app/model/filter.dart';
import 'package:note_app/model/note.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/service/notes_service.dart';
import 'package:note_app/styles.dart';
import 'package:note_app/widget/drawer.dart';
import 'package:note_app/widget/note_grid.dart';
import 'package:note_app/widget/note_list.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with CommandHandler {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _girdView = true;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => NoteFilter(),
            ),
            Consumer<NoteFilter>(
              builder: (context, filter, child) => StreamProvider.value(
                value: _createNoteStream(context, filter),
                child: child,
              ),
            ),
          ],
          child: Consumer2<NoteFilter, List<Note>>(
            builder: (context, filter, notes, child) {
              final hasNotes = notes?.isNotEmpty == true;
              final canCreate = filter.noteState.canCreate;
              return Scaffold(
                key: _scaffoldKey,
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 720),
                    child: CustomScrollView(
                      slivers: <Widget>[
                        _appBar(context),
                        if (hasNotes)
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),
                        ..._buildNotesView(context, filter, notes),
                        if (hasNotes)
                          SliverToBoxAdapter(
                            child: SizedBox(height: kBottomBarSize + 10),
                          )
                      ],
                    ),
                  ),
                ),
                drawer: AppDrawer(),
                floatingActionButton: canCreate ? _fab(context) : null,
                bottomNavigationBar: canCreate ? _bottomActions() : null,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                extendBody: true,
              );
            },
          ),
        ),
      );

  Widget _fab(BuildContext context) => FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.pushNamed(context, '/note');
        },
      );

  Widget _appBar(BuildContext context) => SliverAppBar(
        floating: true,
        snap: true,
        title: _topActions(context),
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      );

  Widget _topActions(context) => Container(
        //constraints: BoxConstraints(maxWidth: 720),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                InkWell(
                  child: const Icon(Icons.menu),
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search your notes',
                    style: TextStyle(fontSize: 16, color: kHintTextColorLight),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  child:
                      Icon(_girdView ? AppIcons.view_list : AppIcons.view_grid),
                  onTap: () {
                    setState(() {
                      _girdView = !_girdView;
                    });
                  },
                ),
                const SizedBox(width: 18),
                _buildAvatar(context),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      );

  Widget _buildAvatar(BuildContext context) {
    final url = Provider.of<CurrentUser>(context)?.data?.photoUrl;
    return CircleAvatar(
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null ? const Icon(Icons.face) : null,
      radius: 17,
    );
  }

  Widget _bottomActions() => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: <Widget>[
              const Icon(AppIcons.checkbox, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.brush_sharp, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.mic, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.insert_photo,
                  size: 26, color: kIconTintLight),
            ],
          ),
        ),
      );

  List<Widget> _buildNotesView(
      BuildContext context, NoteFilter filter, List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      return [_buildBlankView(filter.noteState)];
    }
    final factory = _girdView ? NotesGrid.create : NoteList.create;
    final showPinned = filter.noteState == NoteState.unspecified;

    if (!showPinned) {
      return [
        factory(notes: notes, onTap: _onNoteTap),
      ];
    }

    final partition = _partitionNotes(notes);
    final hasPined = partition.item1.isNotEmpty;
    final hasUnPined = partition.item2.isNotEmpty;

    final _buildLabel = (String label, [double top = 26]) => SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsetsDirectional.only(
              top: top,
              bottom: 25,
              start: 26,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: kHintTextColorLight,
                fontWeight: FontWeights.medium,
                fontSize: 12,
              ),
            ),
          ),
        );
    return [
      if (hasPined) _buildLabel('PINNED'),
      if (hasPined) factory(notes: partition.item1, onTap: _onNoteTap),
      if (hasUnPined && hasPined) _buildLabel('OTHERS'),
      factory(notes: partition.item2, onTap: _onNoteTap),
    ];
  }

  Widget _buildBlankView(NoteState filteredState) => SliverFillRemaining(
        //hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Expanded(flex: 1, child: SizedBox()),
            Icon(
              AppIcons.thumbtack,
              size: 120,
              color: kAccentColorLight.shade300,
            ),
            Expanded(
              flex: 2,
              child: Text(
                filteredState.emptyResultMessage,
                style: TextStyle(
                  color: kHintTextColorLight,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );

  void _onNoteTap(Note note) async {
    final command =
        await Navigator.pushNamed(context, '/note', arguments: {'note': note});
    //debugPrint('_onNoteTap : ${command.message}');
    processNoteCommand(_scaffoldKey.currentState, command);
  }

  /// Create note query
  Stream<List<Note>> _createNoteStream(
      BuildContext context, NoteFilter filter) {
    final user = Provider.of<CurrentUser>(context)?.data;
    final collection = notesCollection(user?.uid);
    final query = filter.noteState == NoteState.unspecified
        ? collection
            .where('state',
                isLessThan: NoteState.archived
                    .index) // show bot normal/pinned notes when no filter specified
            .orderBy('state', descending: true) // pinned notes come first
        : collection.where('state', isEqualTo: filter.noteState.index);
    return query
        .snapshots()
        .handleError((e) => debugPrint('query notes failed: $e'))
        .map((snapshot) => Note.fromQuery(snapshot));
  }

  Tuple2<List<Note>, List<Note>> _partitionNotes(List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      return Tuple2([], []);
    }
    final indexUnpined = notes?.indexWhere((n) => !n.pinned);
    return indexUnpined > -1
        ? Tuple2(notes.sublist(0, indexUnpined), notes.sublist(indexUnpined))
        : Tuple2(notes, []);
  }
}
