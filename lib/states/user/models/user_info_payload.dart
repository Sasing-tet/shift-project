import 'dart:collection' show MapView;
import 'package:flutter/foundation.dart' show immutable;
import 'package:shift_project/states/user/models/firebase_field.firebase.dart';
import '../typedef/user_id.dart';

@immutable
class UserInfoPayload extends MapView <String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? email,
    required String? displayName,
  }) : super({
    FirebaseFieldName.userId: userId,
    FirebaseFieldName.email: email ?? '',
    FirebaseFieldName.displayName: displayName ?? '',
  });
}