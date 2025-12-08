import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// TODO: import halaman list event kalo udh ada
import 'package:sporticket_mobile/event/screens/event_list.dart';
import 'package:sporticket_mobile/event/screens/event_form.dart';
import 'package:sporticket_mobile/screens/login_page.dart'; // nanti dihapus kalo udh ada halaman list event

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Sporticket',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF537FB9),
            primary: const Color(0xFF537FB9),
          ),
          useMaterial3: true,
        ),

        home: const EventListPage(),
      ),
    );
  }
}