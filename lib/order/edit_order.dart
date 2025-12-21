import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/order/create_order.dart';
import 'package:sporticket_mobile/order/history.dart'; 
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';

class EditOrderPage extends StatefulWidget {
  final int orderId;

  const EditOrderPage({
    super.key,
    required this.orderId,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndRedirect();
  }

  Future<void> _loadAndRedirect() async {
    final request = context.read<CookieRequest>();

    try {
      // 1️⃣ Fetch ALL orders
      final response = await request.get(
        "http://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/history-flutter/",
      );

      if (response is! List) {
        throw Exception("Invalid history response");
      }

      // ✅ 2️⃣ PARSE TO MODEL FIRST
      final orders = response
          .map<OrderItem>((e) => OrderItem.fromJson(e))
          .toList();

      // ✅ 3️⃣ Find order using model
      final order = orders.firstWhere(
        (o) => o.orderId == widget.orderId,
        orElse: () => throw Exception("Order not found"),
      );

      // ✅ 4️⃣ Build TicketEntry from model properties
      final ticket = TicketEntry(
        id: order.ticketId,
        eventId: "", // OrderItem doesn't have eventId, that's okay
        category: order.seating,
        price: order.ticketPrice.toDouble(),
        stock: order.ticketStock,
        html: "",
      );

      if (!mounted) return;

      // ✅ 5️⃣ Navigate using model properties
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderFormPage(
            tickets: [ticket],
            eventName: order.eventName,
            eventCategory: _categorizeEvent(order.eventName),
            imagePath: "",
            
            // 🔑 EDIT MODE
            orderId: widget.orderId,
            initialQuantity: order.quantity,
            initialTicketId: ticket.id,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ✅ Helper method for event categorization
  String _categorizeEvent(String eventName) {
    final lower = eventName.toLowerCase();
    if (lower.contains("football")) return "football";
    if (lower.contains("basketball")) return "basketball";
    if (lower.contains("badminton")) return "badminton";
    if (lower.contains("tennis")) return "tennis";
    if (lower.contains("volleyball")) return "volleyball";
    return "football"; // default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Edit failed",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error ?? "Unknown error",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
      ),
    );
  }
}