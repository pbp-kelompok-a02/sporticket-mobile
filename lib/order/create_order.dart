import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/order/history.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';
import 'package:sporticket_mobile/widgets/app_bar.dart';

class OrderFormPage extends StatefulWidget {
  final List<TicketEntry> tickets;
  final String eventName;
  final String eventCategory;
  final String imagePath;

  // EDIT MODE (optional)
  final int? orderId;
  final int? initialQuantity;
  final String? initialTicketId;

  const OrderFormPage({
    super.key,
    required this.tickets,
    required this.eventName,
    required this.eventCategory,
    required this.imagePath,
    this.orderId,
    this.initialQuantity,
    this.initialTicketId,
  });

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _quantityController;
  TicketEntry? _selectedTicket;

  int _quantity = 1;
  String _notifMessage = "";
  Color _notifColor = Colors.transparent;

  @override
@override
void initState() {
 super.initState();

  debugPrint("=== ORDER FORM INIT ===");
  debugPrint("orderId: ${widget.orderId}");
  debugPrint("initialTicketId: ${widget.initialTicketId}");
  debugPrint("initialQuantity: ${widget.initialQuantity}");
  debugPrint("tickets length: ${widget.tickets.length}");

  for (var t in widget.tickets) {
    debugPrint("ticket.id: ${t.id} (${t.id.runtimeType})");
  }
    if (widget.orderId != null) {
    _quantity = widget.initialQuantity ?? 1;

    try {
      _selectedTicket = widget.tickets.firstWhere(
        (t) => t.id.toString() == widget.initialTicketId.toString(),
      );
      debugPrint("MATCH FOUND");
    } catch (e) {
      debugPrint("❌ NO MATCH FOUND — FALLING BACK");
      _selectedTicket = widget.tickets.isNotEmpty ? widget.tickets.first : null;
    }
  } else {
    _quantity = 1;
    _selectedTicket = widget.tickets.isNotEmpty ? widget.tickets.first : null;
  }

  _quantityController = TextEditingController(
    text: _quantity.toString(),
  );
}



  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SporticketAppBar(title: "Create Order"),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.orderId != null ? "EDIT ORDER" : "ORDER",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // const SizedBox(height: 15),
            // _buildEventHeader(),
            const SizedBox(height: 20),
            Center(child: _buildStadiumImage()),
            const SizedBox(height: 30),
            Center(child: _buildFormSection()),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ================= FORM =================
  Widget _buildFormSection() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, spreadRadius: 2)
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           if (_notifMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _notifColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _notifMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          const Text("Ticket Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(),
            onChanged: (value) => _quantity = int.tryParse(value) ?? 1,
            validator: (value) {
              if (value == null || value.isEmpty) return "Required";
              if (int.tryParse(value) == null) return "Must be a number";
              return null;
            },
          ),

          const SizedBox(height: 20),
          const Text("Seating Location", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          DropdownButtonFormField<TicketEntry>(
            value: _selectedTicket,
            decoration: _inputDecoration(),
            items: widget.tickets.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(
                  "${t.category} — \$${t.price.toStringAsFixed(0)} (Left: ${t.stock})",
                ),
              );
            }).toList(),
          onChanged: (value) => setState(() => _selectedTicket = value),
          ),

          const SizedBox(height: 25),
          Text("Price: \$${_selectedTicket?.price.toStringAsFixed(0)}"),
          Text("Stock: ${_selectedTicket?.stock}"),

          const SizedBox(height: 25),
          _buildButtons(),
        ]),
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _buildButtons() {
    final request = context.watch<CookieRequest>();

    Future<void> _submitOrder(String status) async {
      if (!_formKey.currentState!.validate()) return;

      final ticket = _selectedTicket!;
      final qty = _quantity;

      final bool isEdit = widget.orderId != null;

        if (qty > ticket.stock) {
        setState(() {
          _notifMessage = "❌ Stock insufficient. Only ${ticket.stock} left";
          _notifColor = Colors.red;
        });
        return;
  }
  
      final url = isEdit
          ? "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/edit-flutter/${widget.orderId}/"
          : "https://laudya-michelle-sporticket.pbp.cs.ui.ac.id/order/create-flutter/${ticket.id}/";

     final payload = isEdit
            ? {
                "quantity": qty,
                "ticket_id": _selectedTicket!.id,
              }
            : {
                "quantity": qty,
                "status": status,
              };

      try {
        final response = await request.postJson(url, jsonEncode(payload));

        if (!mounted) return;

        if (response["success"] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
          );
        } else {
          setState(() {
            _notifMessage = "❌ ${response['error']}";
            _notifColor = Colors.red;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _submitOrder("confirmed"),
          child: const Text("Purchase"),
        ),
      ),
      const SizedBox(height: 12),
      if (widget.orderId == null)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitOrder("pending"),
            child: const Text("Save Ticket"),
          ),
        ),
    ]);
  }

  // ================= UI HELPERS =================
    Widget _buildStadiumImage() =>
        Image.asset(
          seatingPlanAsset,
          height: 220,
          fit: BoxFit.contain,
        );

  Widget _buildBottomNavBar() => const SizedBox(height: 0);

  InputDecoration _inputDecoration() => const InputDecoration(
        border: OutlineInputBorder(),
      );


   String get seatingPlanAsset {
  switch (widget.eventCategory.toLowerCase()) {
    case 'football':
      return 'images/ticket/football.png';
    case 'basketball':
      return 'images/ticket/basketball.png';
    case 'badminton':
      return 'images/ticket/badminton.png';
    case 'tennis':
      return 'images/ticket/tennis.png';
    case 'volleyball':
      return 'images/ticket/volleyball.png';
    default:
      return 'images/ticket/football.png';
  }
}
   
}
