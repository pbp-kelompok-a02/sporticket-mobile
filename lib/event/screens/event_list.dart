import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/event/models/event.dart';
import 'package:sporticket_mobile/event/screens/event_detail.dart';
import 'package:sporticket_mobile/event/widgets/event_card.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';
import 'package:sporticket_mobile/event/screens/event_form.dart';
import 'package:sporticket_mobile/models/profile.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  Category _selectedCategory = Category.ALL;
  List<Events> allEvents = [];
  bool isLoading = true;
  String? errorMessage;
  bool isAdmin = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _checkAdminStatus();
  }

  // load event function (useful for reload too)
  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final events = await fetchEventsFromBackend(request);

      setState(() {
        allEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load events: $e';
        isLoading = false;
      });
      print('Error loading events: $e');
    }
  }

  Future<void> _checkAdminStatus() async {
    final request = Provider.of<CookieRequest>(context, listen: false);

    try {
      // TODO: ganti link ke pws
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

  // Fetch event from django
  Future<List<Events>> fetchEventsFromBackend(CookieRequest request) async {
    // TODO: Replace the URL with your app's URL and don't forget to add a trailing slash (/)
    // To connect Android emulator with Django on localhost, use URL http://10.0.2.2:8000/
    // If you're using Chrome, use URL http://localhost:8000/
    // For physical device: Your server's actual IP address

    try {
      // TODO: ganti link ke pws
      final response = await request.get('http://127.0.0.1:8000/events/json/');

      // Decode response to json format
      var data = response;

      // Convert json data to Events objects
      List<Events> listEvents = [];
      for (var d in data) {
        if (d != null) {
          try {
            listEvents.add(Events.fromJson(d));
          } catch (e) {
            print('Error parsing event JSON: $e');
          }
        }
      }
      return listEvents;
    } catch (e) {
      print('Error in fetchEventsFromBackend: $e');
      rethrow; // Re-throw the error so _loadEvents can catch it
    }
  }

  // list of filtered event
  List<Events> get filteredEvents {
    if (_selectedCategory == Category.ALL) {
      return allEvents;
    }
    return allEvents.where((event) => event.category == _selectedCategory).toList();
  }

  String _getCategoryLabel(Category category) {
    switch (category) {
      case Category.ALL:
        return 'All';
      case Category.BADMINTON:
        return 'Badminton';
      case Category.BASKETBALL:
        return 'Basketball';
      case Category.FOOTBALL:
        return 'Football';
      case Category.TENNIS:
        return 'Tennis';
      case Category.VOLLEYBALL:
        return 'Volleyball';
    }
  }

  // function to redirect to event detail
  void _navigateToEventDetail(Events event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    );

    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SporticketAppBar(title: 'Upcoming Events'),
      body: Container(
        // background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // category filter and refresh
            if (!isLoading)
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Filter buttons selections
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Category.values.length,
                        itemBuilder: (context, index) {
                          final category = Category.values[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: 8,
                              left: index == 0 ? 0 : 0,
                            ),
                            child: FilterChip(
                              label: Text(_getCategoryLabel(category)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              checkmarkColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[700],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),

                    // Refresh
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: _loadEvents,
                        tooltip: 'Refresh Events',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),

            // Event list and loading/error state
            Expanded(
              child: isLoading
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading Events...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : errorMessage != null
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadEvents,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : filteredEvents.isEmpty
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try selecting a different category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadEvents,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: EventCard(
                            event: filteredEvents[index],
                            onTap: () => _navigateToEventDetail(filteredEvents[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // create event admin crud (test later)
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormPage(),
            ),
          ).then((createdEvent) {
            if (createdEvent == true) {
              _loadEvents();
            }
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Create New Event',
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // temporary navbar
      bottomNavigationBar: BottomNavBarWidget(),
    );
  }
}