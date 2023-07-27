import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  String role;

  User(
      {required this.userId,
      required this.username,
      required this.password,
      required this.firstName,
      required this.lastName,
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
