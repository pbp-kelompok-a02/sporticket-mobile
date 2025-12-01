
import 'package:flutter/material.dart';

class OrderFormPage extends StatefulWidget {
  final List<TicketOption> tickets;      // list kategori seat dari backend
  final String eventName;                // nama event
  final String eventCategory;            // football, basketball, dll
  final String imagePath;                // path gambar stadion

  const OrderFormPage({
    super.key,
    required this.tickets,
    required this.eventName,
    required this.eventCategory,
    required this.imagePath,
  });

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  TicketOption? _selectedTicket;
  int _quantity = 1;
  String _notifMessage = "";
  Color _notifColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _selectedTicket = widget.tickets.first; // default select
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ========== TOP HEADER ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("ORDER",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700])),
          ),

          const SizedBox(height: 15),

          _buildEventHeader(),

          const SizedBox(height: 20),

          Center(child: _buildStadiumImage()),

          const SizedBox(height: 30),

          Center(child: _buildFormSection()),

          const SizedBox(height: 30),
        ],
      ),
    ),

    // ========== BOTTOM NAVIGATION ==========
    bottomNavigationBar: _buildBottomNavBar(),
  );
}


Widget _buildFormSection() {
  return Container(
    width: 350,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          spreadRadius: 2,
        )
      ],
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          const Text("Ticket Amount",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          TextFormField(
            initialValue: "1",
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(),
            onChanged: (value) =>
                setState(() => _quantity = int.tryParse(value) ?? 1),
            validator: (value) {
              if (value == null || value.isEmpty) return "Required";
              if (int.tryParse(value) == null) return "Must be a number";
              return null;
            },
          ),

          const SizedBox(height: 20),

          const Text("Seating Location",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          DropdownButtonFormField<TicketOption>(
            initialValue: _selectedTicket,
            decoration: _inputDecoration(),
            items: widget.tickets.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text("${t.category} — \$${t.price} (Left: ${t.stock})"),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTicket = value),
          ),

          const SizedBox(height: 25),

          // PRICE + STOCK
          Text("Price: \$${_selectedTicket?.price}",
              style: const TextStyle(fontSize: 16)),
          Text("Stock: ${_selectedTicket?.stock}",
              style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 25),

          // BUTTONS
          _buildButtons(),

          const SizedBox(height: 12),

          // NOTIFICATION
          if (_notifMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _notifColor.withValues(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _notifMessage,
                style: TextStyle(
                  color: _notifColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


  Widget _buildStadiumImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        widget.imagePath,
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }


  Widget _buildEventHeader() {
  return Container(
    height: 130,
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      image: DecorationImage(
        image: AssetImage("assets/event_banner.jpg"), // pakai banner kamu
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.eventName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text("Tanggal Event",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}

Widget _buildButtons() {
  return Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleSubmit("purchase"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Purchase"),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleSubmit("pending"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Save Ticket"),
        ),
      ),
    ],
  );
}

Widget _buildBottomNavBar() {
  return Container(
    color: const Color(0xff6f88b7),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.history, color: Colors.white),
            SizedBox(height: 4),
            Text("HISTORY", style: TextStyle(color: Colors.white)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.home, color: Colors.white),
            SizedBox(height: 4),
            Text("HOME", style: TextStyle(color: Colors.white)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person, color: Colors.white),
            SizedBox(height: 4),
            Text("PROFILE", style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    ),
  );
}



  // ================================
  // SUBMIT HANDLER
  // ================================
  void _handleSubmit(String action) {
    if (!_formKey.currentState!.validate()) return;

    int stock = _selectedTicket!.stock;

    if (_quantity > stock) {
      setState(() {
        _notifMessage = "❌ Jumlah tiket melebihi stok tersedia!";
        _notifColor = Colors.red;
      });
      return;
    }

    setState(() {
      _notifMessage = "✅ ${action == 'purchase' ? "Purchase berhasil!" : "Ticket disimpan!"}";
      _notifColor = Colors.green;
    });

    // TODO: call API Django 
  }

  // Decoration helper
  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}



// Modul ticket
class TicketOption {
  final int id;
  final String category;
  final int price;
  final int stock;

  TicketOption({
    required this.id,
    required this.category,
    required this.price,
    required this.stock,
  });
}



