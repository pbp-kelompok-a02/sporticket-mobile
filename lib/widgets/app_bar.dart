import 'package:flutter/material.dart';

class SporticketAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const SporticketAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_sporticket.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
