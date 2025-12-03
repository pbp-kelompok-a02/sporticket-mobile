// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    int id;
    int userId;
    String username;
    String email;
    String name;
    String role;
    dynamic phoneNumber;
    String profilePhoto;

    Profile({
        required this.id,
        required this.userId,
        required this.username,
        required this.email,
        required this.name,
        required this.role,
        required this.phoneNumber,
        required this.profilePhoto,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        name: json["name"],
        role: json["role"],
        phoneNumber: json["phone_number"],
        profilePhoto: json["profile_photo"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "username": username,
        "email": email,
        "name": name,
        "role": role,
        "phone_number": phoneNumber,
        "profile_photo": profilePhoto,
    };
}
