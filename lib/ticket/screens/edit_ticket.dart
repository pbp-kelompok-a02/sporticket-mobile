import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';

class EditTicketPage extends StatefulWidget {
  final TicketEntry ticket;

  const EditTicketPage({super.key, required this.ticket});

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final _formKey = GlobalKey<FormState>();

  late String _category;
  late double _price;
  late int _stock;

  final List<String> _categories = ['REG', 'VIP'];

  @override
  void initState() {
    super.initState();
    _category = widget.ticket.category;
    _price = widget.ticket.price;
    _stock = widget.ticket.stock;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Back Button ===
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, size: 20, color: Colors.blue),
                      SizedBox(width: 4),
                      Text("Back",
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === Page Title ===
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Edit Ticket",
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ticket ID: ${widget.ticket.id}",
                        style: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // === CARD FORM ===
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
                        // CATEGORY
                        const Text(
                          "Category",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
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

                        // PRICE
                        const Text(
                          "Price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          initialValue: _price.toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
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
                              _price = double.tryParse(value) ?? _price;
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

                        // STOCK
                        const Text(
                          "Stock",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          initialValue: _stock.toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
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
                              _stock = int.tryParse(value) ?? _stock;
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

                        // BUTTON ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Cancel Button
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),

                            // SAVE BUTTON
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final response = await request.postJson(
                                    "http://localhost:8000/ticket/edit-flutter/${widget.ticket.id}/",
                                    jsonEncode({
                                      "category": _category,
                                      "price": _price,
                                      "stock": _stock
                                    }),
                                  );

                                  if (!mounted) return;

                                  if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Ticket successfully updated!")),
                                    );
                                    Navigator.pop(context, true);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Failed to update ticket.")),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}