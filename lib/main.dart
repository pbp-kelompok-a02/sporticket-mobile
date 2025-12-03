import 'package:flutter/material.dart';
// import 'package:sporticket_mobile/ticket/screens/ticket_entry_list.dart';
import 'package:sporticket_mobile/ticket/prototype/event_entry_list.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
// TODO: import halaman list event kalo udh ada
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF537FB9),
            primary: const Color(0xFF537FB9),
          ),
          useMaterial3: true,
        ),
        // TODO: ganti LoginPage dengan halaman list event kalo udh ada
        home: const EventEntryListPage(),
      ),
    );
  }
}