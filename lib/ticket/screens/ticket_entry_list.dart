import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';
import 'package:sporticket_mobile/ticket/widgets/ticket_entry_card.dart';
import 'package:sporticket_mobile/ticket/screens/ticketlist_form.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/ticket/screens/edit_ticket.dart';
import 'package:sporticket_mobile/models/profile.dart';
import 'package:http/http.dart' as http;

class TicketEntryListPage extends StatefulWidget {
  final String matchId;

  const TicketEntryListPage({super.key, required this.matchId});

  @override
  State<TicketEntryListPage> createState() => _TicketEntryListPageState();
}

class _TicketEntryListPageState extends State<TicketEntryListPage> {
  bool isAdmin = false;
  bool isLoading = true;

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get("http://127.0.0.1:8000/account/profile-mobile/");

      if (response["status"] == true) {
        final profile = Profile.fromJson(response["data"]);

        setState(() {
          isAdmin = profile.isSuperuser;
          isLoading = false;
        });
      } else {
        setState(() {
          isAdmin = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
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
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket List'),
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
                  setState(() {}); // REFRESH LIST
                }
              },
            )
        ],
      ),
      body: FutureBuilder(
        future: fetchTicket(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                children: [
                  Text(
                    'There are no tickets yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final ticket = snapshot.data![index];

                  return TicketEntryCard(
                    ticket: ticket,
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text("You clicked on ${ticket.category}")),
                        );
                    },

                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTicketPage(ticket: ticket),
                        ),
                      ).then((updated) {
                        if (updated == true) setState(() {});
                      });
                    },

                    onDelete: () async {
                      final response = await http.post(
                        Uri.parse("http://localhost:8000/ticket/delete-flutter/${ticket.id}/"),
                      );

                      if (response.statusCode == 200) {
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to delete ticket")),
                        );
                      }
                    },
                    isAdmin: isAdmin,
                  );
                }
              );
            }
          }
        },
      ),
    );
  }
}