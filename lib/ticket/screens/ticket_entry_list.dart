import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';
import 'package:sporticket_mobile/ticket/widgets/ticket_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class TicketEntryListPage extends StatefulWidget {
  const TicketEntryListPage({super.key});

  @override
  State<TicketEntryListPage> createState() => _TicketEntryListPageState();
}

class _TicketEntryListPageState extends State<TicketEntryListPage> {
  Future<List<TicketEntry>> fetchTicket(CookieRequest request) async {
    
    final response = await request.get('http://localhost:8000/json/');
    
    // Decode response to json format
    var data = response;
    
    // Convert json data to TicketEntry objects
    List<TicketEntry> listTicket = [];
    for (var d in data) {
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
        title: const Text('Ticket Entry List'),
      ),
      body: FutureBuilder(
        future: fetchTicket(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no ticket in football ticket yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => TicketEntryCard(
                  ticket: snapshot.data![index],
                  onTap: () {
                    // Show a snackbar when ticket card is clicked
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("You clicked on ${snapshot.data![index].title}"),
                        ),
                      );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}