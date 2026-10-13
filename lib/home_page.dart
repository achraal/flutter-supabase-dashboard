import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importation des sous-écrans
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // --- PALETTE DE COULEURS EN MODE SOMBRE (iOS Dark Mode OLED) ---
  static const Color _bgSurface = Color(0xFF000000); // Pure Black OLED
  static const Color _cardBg = Color(0xFF1C1C1E); // Dark Drawer & Container
  static const Color _cardElevatedBg = Color(0xFF2C2C2E); // Inner Items & Separators

  // Accents iOS System Dark
  static const Color _primary = Color(0xFF0A84FF); // Blue iOS Dark
  static const Color _primaryContainer = Color(0xFF003063);
  static const Color _tertiary = Color(0xFF30D158); // Green iOS Dark
  static const Color _tertiaryContainer = Color(0xFF0C3B18);
  static const Color _error = Color(0xFFFF453A); // Red iOS Dark

  // Textes & Neutral Colors
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _outline = Color(0xFF636366);
  static const Color _outlineVariant = Color(0xFF48484A);

  // Récupération des données du profil Supabase
  Future<Map<String, dynamic>?> _getProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Erreur lors du chargement du profil: $e');
      return null;
    }
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF2C2C2E),
        content: Row(
          children: [
            Icon(icon, color: _tertiary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getProfileData(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?['name'] ?? profile?['full_name'] ?? "Alexandre Martin";
        final email = user?.email ?? profile?['email'] ?? "alexandre.martin@supabase.io";
        final avatarUrl = profile?['avatar_url'] as String?;

        // Liste des écrans en mode sombre
        final List<Widget> screens = [
          DashboardScreen(profile: profile),
          ProfileScreen(user: user, profile: profile),
          const NotificationsScreen(),
          const SettingsScreen(),
          const SupportScreen(),
        ];

        return Scaffold(
          backgroundColor: _bgSurface,

          // BARRE SUPÉRIEURE iOS DARK
          appBar: AppBar(
            backgroundColor: _bgSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: _textPrimary),
            title: Text(
              _getAppBarTitle(_currentIndex),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              // Bouton Notifications avec Badge Rouge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: _textPrimary, size: 22),
                    onPressed: () => setState(() => _currentIndex = 2),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _error,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgSurface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              // Avatar cliquable
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _outlineVariant, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: _cardElevatedBg,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 16, color: _textSecondary)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // MENU LATÉRAL iOS DARK
          drawer: Drawer(
            width: 310,
            backgroundColor: _cardBg,
            elevation: 12,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // 1. En-tête profil avec Dégradé Supabase Dark
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00224A),
                        Color(0xFF003E8A),
                        Color(0xFF0058BC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: avatarUrl != null && avatarUrl.isNotEmpty
                                      ? Image.network(avatarUrl, fit: BoxFit.cover)
                                      : Container(
                                    color: _cardElevatedBg,
                                    child: const Icon(Icons.person, size: 30, color: _textSecondary),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: _tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Membre Pro',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: _primary, size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: _tertiary),
                                SizedBox(width: 6),
                                Text(
                                  'Supabase Realtime actif',
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                            Text(
                              '34ms',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Element de navigation
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    children: [
                      _buildDrawerTile(
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        title: 'Tableau de bord',
                        index: 0,
                      ),
                      _buildDrawerTile(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        title: 'Mon Profil',
                        index: 1,
                      ),
                      _buildDrawerTile(
                        icon: Icons.notifications_outlined,
                        activeIcon: Icons.notifications,
                        title: 'Notifications',
                        index: 2,
                        badgeWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      _buildDrawerTile(
                        icon: Icons.analytics_outlined,
                        activeIcon: Icons.analytics,
                        title: 'Analytique',
                        index: 0,
                        isExternalAction: true,
                        onCustomTap: () {
                          Navigator.pop(context);
                          _showSnackBar('Section Analytique synchronisée', Icons.analytics);
                        },
                      ),
                      _buildDrawerTile(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        title: 'Paramètres',
                        index: 3,
                      ),
                      _buildDrawerTile(
                        icon: Icons.help_outline_rounded,
                        activeIcon: Icons.help_rounded,
                        title: 'Aide & Support',
                        index: 4,
                      ),

                      const SizedBox(height: 16),

                      // Bannière d'état Supabase Dark
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardElevatedBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.cloud_sync, color: _primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Base Supabase',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sauvegarde automatique chiffrée de bout en bout opérationnelle.',
                              style: TextStyle(fontSize: 11, color: _textSecondary, height: 1.3),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.78,
                                minHeight: 4,
                                backgroundColor: _cardBg,
                                valueColor: AlwaysStoppedAnimation<Color>(_primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: _cardElevatedBg, indent: 16, endIndent: 16),

                // 3. Pied de Drawer : Déconnexion
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A100D),
                            foregroundColor: _error,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: _cardBg,
                                title: const Text('Déconnexion', style: TextStyle(color: _textPrimary)),
                                content: const Text(
                                  'Souhaitez-vous vraiment fermer votre session Supabase ?',
                                  style: TextStyle(color: _textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Annuler', style: TextStyle(color: _outline)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context); // Fermer le drawer
                                      await Supabase.instance.client.auth.signOut();
                                    },
                                    child: const Text('Déconnexion', style: TextStyle(color: _error, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text(
                            'Déconnexion',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'v2.4.0 (Flutter & Supabase)',
                        style: TextStyle(fontSize: 11, color: _outline, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CORPS DE PAGE DYNAMIQUE SANS RECHARGEMENT
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // BARRE DE NAVIGATION INFÉRIEURE iOS DARK MODE
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: _bgSurface,
              border: Border(
                top: BorderSide(color: _cardElevatedBg, width: 0.5),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  labelTextStyle: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary);
                    }
                    return const TextStyle(fontSize: 11, color: _textSecondary);
                  }),
                ),
              ),
              child: NavigationBar(
                height: 64,
                selectedIndex: _currentIndex,
                onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                indicatorColor: _primaryContainer,
                backgroundColor: _bgSurface,
                elevation: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined, size: 22, color: _textSecondary),
                    selectedIcon: Icon(Icons.dashboard, color: _primary, size: 22),
                    label: 'Tableau',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline, size: 22, color: _textSecondary),
                    selectedIcon: Icon(Icons.person, color: _primary, size: 22),
                    label: 'Profil',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_outlined, size: 22, color: _textSecondary),
                    selectedIcon: Icon(Icons.notifications, color: _primary, size: 22),
                    label: 'Flux',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined, size: 22, color: _textSecondary),
                    selectedIcon: Icon(Icons.settings, color: _primary, size: 22),
                    label: 'Compte',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.help_outline_rounded, size: 22, color: _textSecondary),
                    selectedIcon: Icon(Icons.help_rounded, color: _primary, size: 22),
                    label: 'Aide',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    Widget? badgeWidget,
    bool isExternalAction = false,
    VoidCallback? onCustomTap,
  }) {
    final isSelected = !isExternalAction && _currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onCustomTap ??
                () {
              setState(() => _currentIndex = index);
              Navigator.pop(context);
            },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 20,
                    color: isSelected ? _primary : _textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? _primary : _textPrimary,
                    ),
                  ),
                ],
              ),
              if (badgeWidget != null)
                badgeWidget
              else if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const Icon(Icons.chevron_right, size: 16, color: _outline),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Tableau de bord';
      case 1:
        return 'Mon Profil';
      case 2:
        return 'Notifications';
      case 3:
        return 'Réglages';
      case 4:
        return 'Aide & Support';
      default:
        return 'Accueil';
    }
  }
}