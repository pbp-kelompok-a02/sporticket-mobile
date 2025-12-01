// To parse this JSON data, do
//
//     final ticketEntry = ticketEntryFromJson(jsonString);

import 'dart:convert';

List<TicketEntry> ticketEntryFromJson(String str) => List<TicketEntry>.from(json.decode(str).map((x) => TicketEntry.fromJson(x)));

String ticketEntryToJson(List<TicketEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketEntry {
    String id;
    String eventId;
    String category;
    int price;
    int stock;
    String html;

    TicketEntry({
        required this.id,
        required this.eventId,
        required this.category,
        required this.price,
        required this.stock,
        required this.html,
    });

    factory TicketEntry.fromJson(Map<String, dynamic> json) => TicketEntry(
        id: json["id"],
        eventId: json["event_id"],
        category: json["category"],
        price: json["price"],
        stock: json["stock"],
        html: json["html"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "event_id": eventId,
        "category": category,
        "price": price,
        "stock": stock,
        "html": html,
    };
}