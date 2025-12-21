import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sporticket_mobile/ticket/models/ticket_entry.dart';

class TicketEntryCard extends StatelessWidget {
  final TicketEntry ticket;
  final String eventCategory;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool isAdmin;

  const TicketEntryCard({
    super.key,
    required this.ticket,
    required this.eventCategory,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.isAdmin,
  });

  bool get isSoldOut => ticket.stock <= 0;

  String get ticketImage {
    final sport = eventCategory.toLowerCase();
    final type = ticket.category.toUpperCase();
    return 'images/ticket/${type}_$sport.png';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSoldOut) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Sorry, this ticket is sold out.'),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
        } else {
          onTap();
        }
      },
      child: Opacity(
        opacity: isSoldOut ? 0.7 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(ticketImage),
              fit: BoxFit.cover,
            ),
          ),

          child: Stack(
            children: [
              // ===== Overlay gelap =====
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.25),
                ),
              ),

              // ===== SOLD OUT WATERMARK =====
              if (isSoldOut)
                Positioned.fill(
                  child: Center(
                    child: Transform.rotate(
                      angle: -pi / 8,
                      child: Image.asset(
                        'images/ticket/sold-out.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

              // ===== BADGE KATEGORI (REG / VIP) =====
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ===== HARGA =====
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "\$ ${ticket.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // ===== SISA TIKET =====
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4B63D9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    ticket.stock > 0
                        ? "Only ${ticket.stock} ticket${ticket.stock > 1 ? 's' : ''} left!"
                        : "Sold Out",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ===== ADMIN BUTTON =====
              if (isAdmin)
                Positioned(
                  top: 50,
                  right: 12,
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}