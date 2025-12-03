import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/prototype/event_entry.dart';
import 'package:sporticket_mobile/ticket/prototype/event_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EventEntryListPage extends StatefulWidget {
  const EventEntryListPage({super.key});

  @override
  State<EventEntryListPage> createState() => _EventEntryListPageState();
}

class _EventEntryListPageState extends State<EventEntryListPage> {
  Future<List<EventEntry>> fetchEvent(CookieRequest request) async {
    
    final response = await request.get('http://localhost:8000/events/json/');
    
    // Decode response to json format
    var data = response;
    
    // Convert json data to EventEntry objects
    List<EventEntry> listEvent = [];
    for (var d in data) {
      if (d != null) {
        listEvent.add(EventEntry.fromJson(d));
      }
    }
    return listEvent;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPORTICKET'),
      ),
      body: FutureBuilder(
        future: fetchEvent(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no event in football event yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => EventEntryCard(
                  event: snapshot.data![index],
                  onTap: () {
                    // Show a snackbar when event card is clicked
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