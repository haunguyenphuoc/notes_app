import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _goolgeSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  final _loginForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loggingIn = false;
  bool _useEmailSignIn = false;
  String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Theme(
      data: ThemeData(primarySwatch: kAccentColorLight).copyWith(
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: kAccentColorLight,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      child: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 48),
            child: Form(
              key: _loginForm,
              child: Column(
                children: <Widget>[
                  Image.asset('assets/images/thumbtack_intro.png'),
                  const SizedBox(
                    height: 32,
                  ),
                  const Text(
                    'Capture anything',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  if (_useEmailSignIn) ..._buildEmailSignInFields(),
                  if (!_useEmailSignIn) ..._buildGoogleSignInFields(),
                  if (_errorMessage != null) _buildLoginMessage(),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  List<Widget> _buildEmailSignInFields() => [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email',
          ),
          validator: (value) =>
              value.isEmpty ? 'Please input your email' : null,
        ),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(hintText: 'Password'),
          validator: (value) =>
              value.isEmpty ? 'Please input your password' : null,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildEmailSignInButton(),
        if (_loggingIn) const LinearProgressIndicator(),
        FlatButton(
          child: Text('Use Google Sign In'),
          onPressed: () => setState(() {
            _useEmailSignIn = false;
          }),
        ),
      ];
  List<Widget> _buildGoogleSignInFields() => [
        RaisedButton(
          padding: const EdgeInsets.all(0),
          onPressed: _signInWithGoogle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/google.png',
                width: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40 / 1.618),
                child: const Text('Continue with Google'),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        FlatButton(
          child: Text('Sign in with Email'),
          onPressed: () => setState(() {
            _useEmailSignIn = true;
          }),
        ),
        if (_loggingIn)
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 12),
            child: const CircularProgressIndicator(),
          ),
      ];

  Widget _buildLoginMessage() => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          _errorMessage,
          style: const TextStyle(
            fontSize: 14,
            color: kErrorColorLight,
          ),
        ),
      );
  Widget _buildEmailSignInButton() => RaisedButton(
        onPressed: _signInWithEmail,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: const Text('Sign in / Sign up'),
        ),
      );

  void _signInWithEmail() async {
    if (_loginForm.currentState?.validate() != true) return;

    FocusScope.of(context).unfocus();

    String errMsg;
    try {
      _setLogginIn();
      final result =
          await _doEmailSignIn(_emailController.text, _passwordController.text);
      debugPrint('Login result: $result');
    } on PlatformException catch (e) {
      errMsg = e.message;
    } catch (e, s) {
      debugPrint('login failed: $e. $s');
      errMsg = 'Login failed, please try again later.';
    } finally {
      _setLogginIn(false, errMsg);
    }
  }

  void _signInWithGoogle() async {
    _setLogginIn();
    String errMsg;

    try {
      final googleUser = await _goolgeSignIn.signIn();
      final googleAuth = await googleUser.authentication;
      debugPrint('idToken: ' + googleAuth.idToken);
      debugPrint('accessToken: ' + googleAuth.accessToken);
      final credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      await _auth.signInWithCredential(credential);
    } catch (e, s) {
      debugPrint('goolge signIn failed: $e. $s');
      errMsg = 'Login failed, please try again later.';
    } finally {
      _setLogginIn(false, errMsg);
    }
  }

  Future<AuthResult> _doEmailSignIn(String email, String password,
          {bool signUp = false}) =>
      (signUp
              ? _auth.createUserWithEmailAndPassword(
                  email: email, password: password)
              : _auth.signInWithEmailAndPassword(
                  email: email, password: password))
          .catchError((e) {
        if (e is PlatformException && e.code == 'ERROR_USER_NOT_FOUND') {
          return _doEmailSignIn(email, password, signUp: true);
        } else {
          throw e;
        }
      });

  void _setLogginIn([bool loggingIn = true, String errMsg]) {
    if (mounted) {
      setState(() {
        _loggingIn = loggingIn;
        _errorMessage = errMsg;
      });
    }
  }
}
