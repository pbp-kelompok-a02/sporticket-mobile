// To parse this JSON data, do
//
//     final eventEntry = eventEntryFromJson(jsonString);

import 'dart:convert';

List<EventEntry> eventEntryFromJson(String str) => List<EventEntry>.from(json.decode(str).map((x) => EventEntry.fromJson(x)));

String eventEntryToJson(List<EventEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventEntry {
    String matchId;
    String name;
    String homeTeam;
    String awayTeam;
    String description;
    dynamic poster;
    String venue;
    DateTime date;
    int capacity;
    String category;

    EventEntry({
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

    factory EventEntry.fromJson(Map<String, dynamic> json) => EventEntry(
        matchId: json["match_id"],
        name: json["name"],
        homeTeam: json["home_team"],
        awayTeam: json["away_team"],
        description: json["description"],
        poster: json["poster"],
        venue: json["venue"],
        date: DateTime.parse(json["date"]),
        capacity: json["capacity"],
        category: json["category"],
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
        "category": category,
    };
}
