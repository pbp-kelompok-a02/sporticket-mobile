// To parse this JSON data, do
//
//     final ReviewEntry = ReviewEntryFromJson(jsonString);

import 'dart:convert';

ReviewEntry reviewEntryFromJson(String str) =>
    ReviewEntry.fromJson(json.decode(str));

String reviewEntryToJson(ReviewEntry data) => json.encode(data.toJson());

class ReviewEntry {
  List<Review> reviews;

  ReviewEntry({required this.reviews});

  factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
    reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
  };
}

class Review {
  int id;
  String user;
  int rating;
  String komentar;
  DateTime createdAt;
  bool isCurrentUser;
  String profilePhoto;
  int userId;

  Review({
    required this.id,
    required this.user,
    required this.userId,
    required this.rating,
    required this.komentar,
    required this.createdAt,
    this.isCurrentUser = false,
    required this.profilePhoto,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    user: json["user"],
    userId: json["user_id"],
    rating: json["rating"],
    komentar: json["komentar"],
    createdAt: DateTime.parse(json["created_at"]),
    isCurrentUser: json["is_current_user"] ?? false,
    profilePhoto: (() {
      final raw = json["profile_photo"] ?? '';
      if (raw == null) return '';
      String s = raw.toString();
      if (s.isEmpty) return '';
      if (s.startsWith('http')) return s;
      if (s.startsWith('/')) return 'https://laudya-michelle-sporticket.pbp.cs.ui.ac.id' + s;
      return 'https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/' + s;
    })(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user,
    "rating": rating,
    "is_current_user": isCurrentUser,
    "komentar": komentar,
    "created_at": createdAt.toIso8601String(),
    "profile_photo": profilePhoto,
  };
}
