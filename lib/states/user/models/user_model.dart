import 'package:json_annotation/json_annotation.dart';
import 'package:shift_project/states/user/typedef/user_id.dart';
part 'user_model.g.dart';

@JsonSerializable()
class User {
  final UserId userId;
  final String? username;
  final String? password;
  final String email;
  final String displayName;
  final String? firstName;
  final String? lastName;
  String role;

  User(
      {required this.userId,
      required this.email,
      required this.displayName,
      this.username,
      this.password,
      this.firstName,
      this.lastName,
      this.role = 'user'});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     userId: json['userId'],
  //     username: json['username'],
  //     password: json['password'],
  //     firstName: json['firstName'],
  //     lastName: json['lastName'],
  //     role: json['role'],
  //   );
  // }

  // Map<String, dynamic> toJson() => {
  //       'userId': userId,
  //       'username': username,
  //       'password': password,
  //       'firstName': firstName,
  //       'lastName': lastName,
  //       'role': role,
  //     };

  @override
  bool operator ==(covariant User other) => userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
