import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/ticket/screens/ticket_entry_list.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';

class TicketFormPage extends StatefulWidget {
    final String matchId;
    final TicketEntry? ticket;

    const TicketFormPage({
      super.key,
      required this.matchId,
      this.ticket,
    });

    @override
    State<TicketFormPage> createState() => _TicketFormPageState();
}

class _TicketFormPageState extends State<TicketFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _category = "REG"; 
  double _price = 0.0;
  int _stock = 0;
  String eventName = '';
  bool isLoadingEvent = true;
  late bool isEdit;

  final List<String> _categories = [
    'REG',
    'VIP'
  ];

  Future<void> fetchEventName(CookieRequest request) async {
    final response =
        await request.get("http://localhost:8000/events/json/");

    final event = response.firstWhere(
      (e) => e['match_id'] == widget.matchId,
      orElse: () => null,
    );

    if (event != null) {
      setState(() {
        eventName = event['name'];
        isLoadingEvent = false;
      });
    } else {
      setState(() {
        eventName = '-';
        isLoadingEvent = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchEventName(request);

    isEdit = widget.ticket != null;

    if (isEdit) {
      _category = widget.ticket!.category;
      _price = widget.ticket!.price;
      _stock = widget.ticket!.stock;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(

      // drawer: LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back, size: 20, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Back",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          isEdit ? "Edit Ticket" : "Create New Ticket",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          isLoadingEvent
                              ? "Event: Loading..."
                              : "Event: $eventName",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // === CATEGORY ===
                          const Text(
                            "Category",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            value: _category,
                            items: _categories
                                .map((cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _category = val!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Category cannot be empty";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // === PRICE ===
                          const Text(
                            "Price",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            initialValue: isEdit ? _price.toStringAsFixed(0) : '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _price = double.tryParse(value) ?? 0.0;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Price cannot be empty";
                              }
                              if (double.tryParse(value) == null) {
                                return "Invalid price";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // === STOCK ===
                          const Text(
                            "Stock",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            initialValue: isEdit ? _stock.toString() : '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _stock = int.tryParse(value) ?? 0;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Stock cannot be empty";
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null) {
                                return "Invalid stock";
                              }
                              if (parsed <= 0) {
                                return "Stock must be > 0";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          // === BUTTON ROW ===
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cancel Button
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),

                              // Create Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                      final url = isEdit
                                        ? "http://localhost:8000/ticket/edit-flutter/${widget.ticket!.id}/"
                                        : "http://localhost:8000/ticket/create-flutter/";

                                      final response = await request.postJson(
                                        url,
                                        jsonEncode({
                                          "event_id": widget.matchId,
                                          "category": _category,
                                          "price": _price,
                                          "stock": _stock
                                        }),
                                      );
                                      if (context.mounted) {
                                        if (response['status'] == 'success') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text("Ticket successfully saved!"),
                                          ));
                                          Navigator.pop(context, true);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text("Something went wrong, please try again."),
                                          ));
                                        }
                                      }
                                    }
                                  },
                                child: Text(
                                  isEdit ? "Save Changes" : "Create Ticket",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ]
              ),
            )
          ),
        ),
      )
    );
  }
}