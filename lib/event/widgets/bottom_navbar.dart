import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sporticket_mobile/event/screens/event_list.dart';
import 'package:sporticket_mobile/screens/login_page.dart';
import 'package:sporticket_mobile/screens/profile_page.dart';
import 'package:sporticket_mobile/order/history.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  bool _shouldHideForRoute(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    // sembunyikan navbar di halaman login dan register karena udah ada tombol back
    return route.contains('login') ||
        route.contains('register') ||
        context.widget.runtimeType.toString().toLowerCase().contains('login') ||
        context.widget.runtimeType.toString().toLowerCase().contains(
          'register',
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldHideForRoute(context)) {
      return const SizedBox.shrink();
    }

    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    final items = <BottomNavigationBarItem>[
      if (isLoggedIn)
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(isLoggedIn ? Icons.account_circle_outlined : Icons.login),
        label: isLoggedIn ? 'Profile' : 'Login',
      ),
    ];

    int currentIndex = 0;
    final routeName = ModalRoute.of(context)?.settings.name ?? '';

    if (isLoggedIn) {
      if (routeName.contains('history')) {
        currentIndex = 0;
      } else if (routeName.contains('/home') || routeName.isEmpty) {
        currentIndex = 1;
      } else if (routeName.contains('/profile')) {
        currentIndex = 2;
      } else {
        currentIndex = 1;
      }
    } else {
      // kalo blm login: index 0 = Home, index 1 = Login
      if (routeName.contains('/login')) {
        currentIndex = 1;
      } else {
        currentIndex = 0; // home
      }
    }

    void onTap(int index) {
      if (isLoggedIn) {
        // [History, Home, Profile]
        switch (index) {
          case 0:
             if (currentIndex != 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryPage(),
              settings: const RouteSettings(name: '/history'),
            ),
            (route) => false,
          );
        }
            
            break;
          case 1:
            if (currentIndex != 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const EventListPage(),
                  settings: const RouteSettings(name: '/home'),
                ),
                (route) => false,
              );
            }
            break;
          case 2:
            if (currentIndex != 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                  settings: const RouteSettings(name: '/profile'),
                ),
              );
            }
            break;
        }
      } else {
        // [Home, Login]
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const EventListPage(),
                  settings: const RouteSettings(name: '/home'),
                ),
                (route) => false,
              );
            }
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
                settings: const RouteSettings(name: '/login'),
              ),
            );
            break;
        }
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: items,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.primary,
    );
  }
}