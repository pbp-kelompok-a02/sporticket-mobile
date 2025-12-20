import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';

class TicketEntryCard extends StatelessWidget {
  final TicketEntry ticket;
  final VoidCallback onTap;

  // Tambahkan 2 callback baru untuk edit & delete
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool isAdmin;

  const TicketEntryCard({
    super.key,
    required this.ticket,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,                        
        borderRadius: BorderRadius.circular(8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Tombol Edit & Delete ===
                if (isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),

                // Category
                Text(
                  ticket.category,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Price
                Text(
                  "Price: \$${ticket.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),

                // Stock
                Text(
                  "Stock: ${ticket.stock}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}