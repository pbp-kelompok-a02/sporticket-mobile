import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/event/models/event.dart';
import 'package:sporticket_mobile/event/screens/event_form.dart';
import 'package:sporticket_mobile/ticket/screens/ticket_entry_list.dart';
import 'package:sporticket_mobile/models/profile.dart';
import 'package:sporticket_mobile/screens/login_page.dart';
import 'package:sporticket_mobile/review/widgets/review_preview_section.dart';

// TODO: Integrate user admin authentication
// TODO: integrate ticket and reviews

class EventDetailPage extends StatefulWidget {
  final Events event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isLoading = true;
  bool isAdmin = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // check if user is admin
  Future<void> _checkAdminStatus() async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    try {
      final response = await request.get("http://127.0.0.1:8000/account/profile-mobile/");

      if (response["status"] == true) {
        final profile = Profile.fromJson(response["data"]);

        setState(() {
          isLoggedIn = true;       
          isAdmin = profile.isSuperuser;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoggedIn = false;      
          isAdmin = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoggedIn = false;
        isAdmin = false;
        isLoading = false;
      });
    }
  }

  // Delete event function
  Future<void> _deleteEvent(BuildContext context) async {

    // confirmation message
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final request = Provider.of<CookieRequest>(context, listen: false);

        final response = await request.postJson(
          'http://localhost:8000/events/delete-flutter/${widget.event.matchId}/',
          jsonEncode({}),

        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh parent
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Navigate to edit page
  void _editEvent() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormPage(event: widget.event),
      ),
    ).then((value) {
      if (value == true) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image poster
            widget.event.poster != null && widget.event.poster!.isNotEmpty
                ? Image.network(
              'http://localhost:8000/proxy-image/?url=${Uri.encodeComponent(widget.event.poster!)}',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      getCategoryIcon(widget.event.category),
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            )
            // No image (icon only)
                : Container(
              height: 250,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  getCategoryIcon(widget.event.category),
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),
            // Event name and category
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categoryValues.reverse[widget.event.category]!.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // team vs team text
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home Team',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.homeTeam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Away Team',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.awayTeam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // venue date and capacity info
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.location_on, 'Venue', widget.event.venue),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(widget.event.date)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.people, 'Capacity', '${widget.event.capacity} people'),
                  const SizedBox(height: 24),

                  // desc
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  // Admin CRUD
                  const SizedBox(height: 32),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (isAdmin)
                    Column(
                      children: [
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _editEvent,
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Event'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _deleteEvent(context),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete Event'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!isLoggedIn) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LoginPage(),
                            ),
                            (route) => false,
                          );  
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketEntryListPage(
                              matchId: widget.event.matchId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('See Tickets'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )  
                ],
              ),
            ),
                  const SizedBox(height: 24),

                  // --- Reviews Preview ---
                  ReviewPreviewSection(
                    matchId: widget.event.matchId.toString(),
                  ),
          ],
        ),
      ),
    );
  }

  // helper function for info (date place and capacity)
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}