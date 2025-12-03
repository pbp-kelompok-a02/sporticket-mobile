import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/prototype/event_entry.dart';
import 'package:sporticket_mobile/ticket/screens/ticket_entry_list.dart';

class EventEntryCard extends StatelessWidget {
  final EventEntry event;
  final VoidCallback onTap;

  const EventEntryCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // === POSTER ===
              if (event.poster != null && event.poster!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    event.poster!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // === EVENT NAME ===
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // === MATCH TEAMS ===
                    Text(
                      "${event.homeTeam} vs ${event.awayTeam}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // === VENUE ===
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(event.venue),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // === DATE ===
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(event.date.toString()),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // === CATEGORY ===
                    Row(
                      children: [
                        const Icon(Icons.sports, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          event.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // === CTA BUTTON ===
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketEntryListPage(
                              matchId: event.matchId,   // <<=== KIRIM MATCH ID !!!
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text("View Tickets"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
