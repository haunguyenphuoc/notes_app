import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/model/user.dart';
import 'package:note_app/screen/home_screen.dart';
import 'package:note_app/screen/login_screen.dart';
import 'package:note_app/screen/note_editor.dart';
import 'package:note_app/screen/settings_srceen.dart';
import 'package:note_app/styles.dart';
import 'package:provider/provider.dart';

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamProvider.value(
        value: FirebaseAuth.instance.onAuthStateChanged
            .map((user) => CurrentUser.create(user)),
        initialData: CurrentUser.inital,
        child: Consumer<CurrentUser>(
          builder: (context, user, _) => MaterialApp(
            title: 'Flutter Keep',
            theme: Theme.of(context).copyWith(
              brightness: Brightness.light,
              primaryColor: Colors.white,
              accentColor: kAccentColorLight,
              appBarTheme: AppBarTheme.of(context).copyWith(
                elevation: 0,
                brightness: Brightness.light,
                iconTheme: IconThemeData(
                  color: kIconTintLight,
                ),
              ),
              scaffoldBackgroundColor: Colors.white,
              bottomAppBarColor: kBottomAppBarColorLight,
              primaryTextTheme: Theme.of(context).primaryTextTheme.copyWith(
                    //title
                    headline: const TextStyle(
                      color: kIconTintLight,
                    ),
                  ),
            ),
            home: user.isInitialValue
                ? Scaffold(
                    body: const SizedBox(),
                  )
                : user.data != null ? HomeScreen() : LoginScreen(),
            routes: {
              '/settings': (_) => SettingScreen(),
            },
            onGenerateRoute: _generateRoute,
          ),
        ),
      );

  /// Handle naned route
  Route _generateRoute(RouteSettings settings) {
    try {
      return _doGenerateRoute(settings);
    } catch (e, s) {
      debugPrint("failed to generate route for $settings: $e $s");
      return null;
    }
  }

  Route _doGenerateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) return null;

    final uri = Uri.parse(settings.name);
    debugPrint('settings:' + settings.name);
    debugPrint('uri:' + uri.path);
    final path = uri.path ?? '';
    switch (path) {
      case '/note':
        {
          // final note = (settings.arguments as Map ?? {})['note'];
          return _buildRoute(settings, (_) => NoteEditor());
        }
      default:
        return null;
    }
  }

  /// Create a [Route]
  Route _buildRoute(RouteSettings settings, WidgetBuilder builder) =>
      MaterialPageRoute<void>(settings: settings, builder: builder);
}
