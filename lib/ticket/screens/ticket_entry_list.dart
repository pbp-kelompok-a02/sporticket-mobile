import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';
import 'package:sporticket_mobile/ticket/widgets/ticket_entry_card.dart';
import 'package:sporticket_mobile/ticket/screens/ticketlist_form.dart';
import 'package:sporticket_mobile/models/profile.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';
import 'package:sporticket_mobile/order/create_order.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';

class TicketEntryListPage extends StatefulWidget {
  final String matchId;

  const TicketEntryListPage({super.key, required this.matchId});

  @override
  State<TicketEntryListPage> createState() => _TicketEntryListPageState();
}

class _TicketEntryListPageState extends State<TicketEntryListPage> {
  bool isAdmin = false;
  bool isLoading = true;

  String eventName = '';
  String eventCategory = '';
  String eventTeam = '';
  DateTime? eventDate;
  String eventVenue = '';

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get("http://127.0.0.1:8000/account/profile-mobile/");

      if (response["status"] == true) {
        final profile = Profile.fromJson(response["data"]);
        isAdmin = profile.isSuperuser;
      }
    } catch (_) {}
  }

  Future<void> fetchEvent(CookieRequest request) async {
    final response = await request.get("http://localhost:8000/events/json/");

    final event = response.firstWhere(
      (e) => e['match_id'] == widget.matchId,
      orElse: () => null,
    );

    if (event != null) {
      setState(() {
        eventName = event['name'];
        eventTeam = "${event['home_team']} vs ${event['away_team']}";
        eventCategory = event['category'];
        if (event['date'] != null) {
          eventDate = DateTime.parse(event['date']); 
        }
        eventVenue = event['venue']; 
      });
    }
  }

  Future<List<TicketEntry>> fetchTicket(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/ticket/json/${widget.matchId}/');
    List<TicketEntry> listTicket = [];

    for (var d in response) {
      if (d != null) {
        listTicket.add(TicketEntry.fromJson(d));
      }
    }

    return listTicket;
  }

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _checkAdminStatus();
    fetchEvent(request);
    setState(() => isLoading = false);
  }

  String get seatingPlanAsset {
    switch (eventCategory.toLowerCase()) {
      case 'football':
        return 'images/ticket/football.png';
      case 'basketball':
        return 'images/ticket/basketball.png';
      case 'badminton':
        return 'images/ticket/badminton.png';
      case 'tennis':
        return 'images/ticket/tennis.png';
      case 'volleyball':
        return 'images/ticket/volleyball.png';
      default:
        return 'images/ticket/football.png';
    }
  }

  String get bannerAsset {
    switch (eventCategory.toLowerCase()) {
      case 'football':
        return 'images/ticket/banner_football.jpeg';
      case 'basketball':
        return 'images/ticket/banner_basketball.jpeg';
      case 'badminton':
        return 'images/ticket/banner_badminton.jpeg';
      case 'tennis':
        return 'images/ticket/banner_tennis.jpeg';
      case 'volleyball':
        return 'images/ticket/banner_volleyball.jpeg';
      default:
        return 'images/ticket/banner_football.jpeg';
    }
  }

  String get formattedEventDate {
  if (eventDate == null) return '';
  return '${eventDate!.month}/${eventDate!.day}/${eventDate!.year}, '
         '${eventDate!.hour.toString().padLeft(2, '0')}:'
         '${eventDate!.minute.toString().padLeft(2, '0')}';
}

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      appBar: SporticketAppBar(
        title: 'Ticket List',
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketFormPage(matchId: widget.matchId),
                  ),
                );

                if (updated == true) {
                  setState(() {}); 
                }
              },
            )
        ],
      ),
      bottomNavigationBar: BottomNavBarWidget(),
      body: Stack (
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login-background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(bannerAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== EVENT NAME =====
                        Text(
                          eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ===== EVENT TEAM =====
                        Text(
                          eventTeam,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ===== DATE =====
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              formattedEventDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ===== VENUE =====
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              eventVenue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Seating Plan
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'SEATING PLAN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset(seatingPlanAsset),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(
                    'The seating plan above shows the arrangement of seats for this event. '
                    'Please check your ticket category (VIP or Regular) to locate your designated area.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // List Ticket
                FutureBuilder<List<TicketEntry>>(
                  future: fetchTicket(request),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    } 

                    // Ketika list ticket kosong
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/ticket/no-ticket.png',
                                width: 120,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No ticket found',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tickets for this event are not available yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: snapshot.data!.map((ticket) {
                        return TicketEntryCard(
                          ticket: ticket,
                          eventCategory: eventCategory,
                          isAdmin: isAdmin,
                          // Menuju halaman order (user) atau edit (admin)
                          onTap: () async {
                            if (isAdmin) {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TicketFormPage(
                                    matchId: widget.matchId,
                                    ticket: ticket,
                                  ),
                                ),
                              );

                              if (updated == true) {
                                setState(() {});
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderFormPage(
                                    tickets: [ticket],
                                    eventName: eventName,
                                    eventCategory: eventCategory,
                                    imagePath: bannerAsset,
                                  ),
                                ),
                              );
                            }
                          },

                          // Menuju halaman edit
                          onEdit: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketFormPage(
                                  matchId: widget.matchId,
                                  ticket: ticket, 
                                ),
                              ),
                            );

                            if (updated == true) {
                              setState(() {});
                            }
                          },

                          // Delete ticket
                          onDelete: () async {
                            final response = await http.post(
                              Uri.parse("http://localhost:8000/ticket/delete-flutter/${ticket.id}/"),
                            );

                            final data = jsonDecode(response.body);

                            if (response.statusCode == 200 && data['status'] == 'success') {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Ticket deleted successfully")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['message'] ?? "Failed to delete ticket")),
                              );
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      )
    );
  }
}