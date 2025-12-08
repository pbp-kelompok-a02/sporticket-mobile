// To parse this JSON data, do
//
//     final events = eventsFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/material.dart';

List<Events> eventsFromJson(String str) => List<Events>.from(json.decode(str).map((x) => Events.fromJson(x)));

String eventsToJson(List<Events> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Events {
  String matchId;
  String name;
  String homeTeam;
  String awayTeam;
  String description;
  String? poster;
  String venue;
  DateTime date;
  int capacity;
  Category category;

  Events({
    required this.matchId,
    required this.name,
    required this.homeTeam,
    required this.awayTeam,
    required this.description,
    required this.poster,
    required this.venue,
    required this.date,
    required this.capacity,
    required this.category,
  });

  factory Events.fromJson(Map<String, dynamic> json) => Events(
    matchId: json["match_id"],
    name: json["name"],
    homeTeam: json["home_team"],
    awayTeam: json["away_team"],
    description: json["description"],
    poster: json["poster"],
    venue: json["venue"],
    date: DateTime.parse(json["date"]),
    capacity: json["capacity"],
    category: categoryValues.map[json["category"]]!,
  );

  Map<String, dynamic> toJson() => {
    "match_id": matchId,
    "name": name,
    "home_team": homeTeam,
    "away_team": awayTeam,
    "description": description,
    "poster": poster,
    "venue": venue,
    "date": date.toIso8601String(),
    "capacity": capacity,
    "category": categoryValues.reverse[category],
  };
}

enum Category {
  ALL, // filter category
  BADMINTON,
  BASKETBALL,
  FOOTBALL,
  TENNIS,
  VOLLEYBALL
}

final categoryValues = EnumValues({
  "badminton": Category.BADMINTON,
  "basketball": Category.BASKETBALL,
  "football": Category.FOOTBALL,
  "tennis": Category.TENNIS,
  "volleyball": Category.VOLLEYBALL
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

// helper function for iconn
IconData getCategoryIcon(Category category) {
  switch (category) {
    case Category.BADMINTON:
      return Icons.sports_tennis;
    case Category.BASKETBALL:
      return Icons.sports_basketball;
    case Category.FOOTBALL:
      return Icons.sports_soccer;
    case Category.TENNIS:
      return Icons.sports_tennis;
    case Category.VOLLEYBALL:
      return Icons.sports_volleyball;
    default:
      return Icons.event;
  }
}