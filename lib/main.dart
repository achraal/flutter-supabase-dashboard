import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase avec `anonKey`
  await Supabase.initialize(
    url: 'https://ipfcgorggndneneasqip.supabase.co',
    anonKey: 'sb_publishable_2p2_-QD0WH2AvKaGgwj5XA_JLL7pm41',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00288E)),
        useMaterial3: true,
      ),
      // Écoute dynamique de la session Supabase
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;

          // Si l'utilisateur est connecté -> Affiche la HomePage
          if (session != null) {
            return const HomePage();
          }

          // Sinon -> Affiche la LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}