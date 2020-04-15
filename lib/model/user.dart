import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

/// A wrapper of [FirebaseUser] provides information to distinguish the initial value
@immutable
class CurrentUser {
  final bool isInitialValue;
  final FirebaseUser data;

  const CurrentUser._(this.data, this.isInitialValue);
  factory CurrentUser.create(FirebaseUser data) => CurrentUser._(data, false);

  /// The inital empty instance.

  static const inital = CurrentUser._(null, true);
}
