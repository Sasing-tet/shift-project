import 'dart:collection';
import 'package:flutter/foundation.dart' show immutable;

import 'firebase_field.firebase.dart';
import '../typedef/user_id.dart';

@immutable
class UserInfoModel extends MapView<String, String?> {
  final UserId userId;
  final String displayName;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? password;

  UserInfoModel({
    required this.userId,
    required this.displayName,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.password,
  }) : super(
          {
            FirebaseFieldName.userId: userId,
            FirebaseFieldName.displayName: displayName,
            FirebaseFieldName.email: email,
            FirebaseFieldName.firstName: firstName,
            FirebaseFieldName.lastName: lastName,
            FirebaseFieldName.username: username,
            FirebaseFieldName.password: password,
          },
        );

  UserInfoModel.fromJson(
    Map<String, dynamic> json, {
    required UserId userId,
  }) : this(
          userId: userId,
          displayName: json[FirebaseFieldName.displayName] ?? '',
          email: json[FirebaseFieldName.email],
          firstName: json[FirebaseFieldName.firstName] ?? '',
          lastName: json[FirebaseFieldName.lastName] ?? '',
          username: json[FirebaseFieldName.username] ?? '',
          password: json[FirebaseFieldName.password] ?? '',
        );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email;

  @override
  int get hashCode => Object.hashAll(
        [
          userId,
          displayName,
          email,
        ],
      );
}
