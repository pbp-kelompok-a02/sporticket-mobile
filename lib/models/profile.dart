// To parse this JSON data, do
//
//    final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    int? id;
    int? userId;
    String username;
    String email;
    String name;
    String role;
    String? phoneNumber;
    String? profilePhoto;

    bool isSuperuser;
    bool isOwnProfile;
    bool canSeeSensitiveData;

    Profile({
        this.id,
        this.userId,
        required this.username,
        required this.email,
        required this.name,
        required this.role,
        this.phoneNumber,
        this.profilePhoto,
        required this.isSuperuser,
        required this.isOwnProfile,
        required this.canSeeSensitiveData,
    });

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        userId: json["user_id"],
        username: json["username"] ?? "",
        email: json["email"] ?? "",
        name: json["name"] ?? "",
        role: json["role"] ?? "Buyer",
        phoneNumber: json["phone_number"],
        profilePhoto: json["profile_photo"],
        isSuperuser: json["is_superuser"] ?? false,
        isOwnProfile: json["is_own_profile"] ?? false,
        canSeeSensitiveData: json["can_see_sensitive_data"] ?? false,
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
        "is_superuser": isSuperuser,
        "is_own_profile": isOwnProfile,
        "can_see_sensitive_data": canSeeSensitiveData,
    };
}