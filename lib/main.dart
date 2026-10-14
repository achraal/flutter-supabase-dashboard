import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. On essaie de charger le .env
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Les variables SUPABASE_URL ou SUPABASE_ANON_KEY sont introuvables dans le fichier .env');
    }

    // 2. On initialise Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
    );

  } catch (e, stackTrace) {
    // S'il y a une erreur, elle s'affichera clairement dans la console
    debugPrint('ERREUR D\'INITIALISATION SUPABASE: $e');
    debugPrint('Stacktrace: $stackTrace');
  }

  runApp(MyApp());
}

final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Mon App Flutter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00288E),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          // Écoute de la session Supabase
          home: StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              final session = Supabase.instance.client.auth.currentSession;

              // Utilisateur connecté
              if (session != null) {
                return const HomePage();
              }

              // Utilisateur non connecté
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}