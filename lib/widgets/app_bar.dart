import 'package:flutter/material.dart';

class SporticketAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SporticketAppBar({
    super.key,
    required this.title,
    this.actions,
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
        if (actions != null) ...actions!,

        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_soccer), 
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