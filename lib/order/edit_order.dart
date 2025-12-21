import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/order/create_order.dart';
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
      // 1️⃣ Fetch ALL orders (already available endpoint)
      final response = await request.get(
        "http://127.0.0.1:8000/order/history-flutter/",
      );

      if (response is! List) {
        throw Exception("Invalid history response");
      }

      // 2️⃣ Find the exact order
      final orderJson = response.firstWhere(
        (o) => o["order_id"] == widget.orderId,
        orElse: () => throw Exception("Order not found"),
      );

      // 3️⃣ Build a SINGLE TicketEntry from order data
      final ticket = TicketEntry(
        id: orderJson["ticket_id"].toString(),
        eventId: orderJson["event_id"].toString(),
        category: orderJson["seating"].toString(),
        price: double.parse(orderJson["ticket_price"].toString()),
        stock: int.parse(orderJson["ticket_stock"].toString()),
        html: "",
      );

      if (!mounted) return;

      // 4️⃣ Go to CREATE ORDER PAGE (but pre-filled)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderFormPage(
            tickets: [ticket], // ✅ EXACT ticket used
            eventName: orderJson["event_name"],
            eventCategory: orderJson["seating"],
            imagePath: "assets/event_banner.jpg",

            // 🔑 EDIT MODE
            orderId: widget.orderId,
            initialQuantity: orderJson["quantity"],
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

  @override
  Widget build(BuildContext context) {
    // This page is NEVER meant to be seen
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text("Edit failed: $_error"),
      ),
    );
  }
}
