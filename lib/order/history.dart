import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';
import 'package:sporticket_mobile/order/edit_order.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';

// ---------------- MODEL ORDER ----------------
class OrderItem {
  final int orderId;
  final String ticketId;
  final String eventName;
  final int quantity;
  final String seating;
  final double price;
  final String status;
  final int ticketStock;
  final double ticketPrice;

  OrderItem({
    required this.orderId,
    required this.ticketId,
    required this.eventName,
    required this.quantity,
    required this.seating,
    required this.price,
    required this.status,
    required this.ticketStock,
    required this.ticketPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json["order_id"],
      ticketId: json["ticket_id"],
      eventName: json["event_name"],
      quantity: json["quantity"],
      seating: json["seating"],
      price: double.parse(json["price"].toString()),
      status: json["status"],
      ticketStock: json["ticket_stock"],
      ticketPrice: json["ticket_price"],
    );
  }
}

// ---------------- HISTORY PAGE ----------------
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {

  // ---------------- FETCH HISTORY ----------------
  Future<List<OrderItem>> fetchOrders(CookieRequest request) async {
    final response = await request.get(
      "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/history-flutter/",
    );

    if (response is! List) {
      throw Exception("History response is not a list");
    }

    return response.map<OrderItem>((e) => OrderItem.fromJson(e)).toList();
  }
  

  // ---------------- EDIT HANDLER (OPTION A) ----------------
void _goToEditOrder(OrderItem order) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditOrderPage(
        orderId: order.orderId, // 🔑 ONLY SOURCE OF TRUTH
      ),
    ),
  ).then((_) => setState(() {})); // refresh after edit
}

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: const SporticketAppBar(title: "History"),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff2f5ff), Color(0xffd3e0fa)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<OrderItem>>(
          future: fetchOrders(request),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(child: Text("No orders yet"));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: orders.map(_buildOrderCard).toList(),
            );
          },
        ),
      ),
        bottomNavigationBar: BottomNavBarWidget()
            );
  }

  // ---------------- ORDER CARD ----------------
  Widget _buildOrderCard(OrderItem order) {
    final bool isPending = order.status == "pending";

    Color statusColor = switch (order.status) {
      "confirmed" => Colors.green,
      "pending" => Colors.orange,
      "cancelled" => Colors.red,
      _ => Colors.black,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.eventName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text("Amount: ${order.quantity}"),
          Text("Seating: ${order.seating}"),
          Text("Price: \$${order.price}"),
          const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (isPending)
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _goToEditOrder(order),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Save Ticket"),
                    onPressed: () async {
                      final request = context.read<CookieRequest>();

                      final response = await request.post(
                        "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/confirm-flutter/${order.orderId}/",
                        {},
                      );

                      if (response["success"] == true) {
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response["error"])),
                        );
                      }
                    },
                  ),

                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      final request = context.read<CookieRequest>();

                      final response = await request.post(
                        "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/cancel-flutter/${order.orderId}/",
                        {},
                      );

                      if (response["success"] == true) {
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response["error"])),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      )

        ],
      ),
    );
  }
  
}
