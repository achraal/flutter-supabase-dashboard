import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;

  const DashboardScreen({super.key, this.profile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- DÉTECTION DU THÈME ---
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // --- PALETTE DE COULEURS DYNAMIQUE (Dark & Light) ---
  Color get _bgSurface => _darkMode ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get _cardBg => _darkMode ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _cardElevatedBg => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  // Accents iOS (Les couleurs principales restent les mêmes, mais les fonds changent)
  Color get _primary => const Color(0xFF0A84FF);
  Color get _primaryContainer => _darkMode ? const Color(0xFF003063) : const Color(0xFFE5F0FF);

  Color get _tertiary => const Color(0xFF30D158);
  Color get _tertiaryContainer => _darkMode ? const Color(0xFF0C3B18) : const Color(0xFFE8F8EB);

  Color get _secondary => const Color(0xFF5E5CE6);
  Color get _secondaryContainer => _darkMode ? const Color(0xFF252361) : const Color(0xFFEBEBFA);

  Color get _error => const Color(0xFFFF453A);
  Color get _errorContainer => _darkMode ? const Color(0xFF4A100D) : const Color(0xFFFFEBEA);

  // Textes & Lignes
  Color get _textPrimary => _darkMode ? Colors.white : Colors.black;
  Color get _textSecondary => const Color(0xFF8E8E93); // Identique en clair/sombre sur iOS
  Color get _dividerColor => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
  Color get _outlineVariant => _darkMode ? const Color(0xFF48484A) : const Color(0xFFD1D1D6);

  @override
  Widget build(BuildContext context) {
    // Attention ici : on ajoute "widget." avant profile car on est passé en StatefulWidget
    final name = widget.profile?['name'] ?? widget.profile?['full_name'] ?? "Alexandre";

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. En-tête : Date, Titre & Avatar
            _buildHeader(),
            const SizedBox(height: 20),

            // 2. Carte d'accueil iOS Dark
            _buildWelcomeCard(name),
            const SizedBox(height: 24),

            // 3. Section Aperçu (Grille 2x2 Widgets)
            _buildSectionHeader('Aperçu', actionText: 'Détails'),
            const SizedBox(height: 10),
            _buildStatGrid(),
            const SizedBox(height: 24),

            // 4. Widget Graphique Activité
            _buildActivityChart(),
            const SizedBox(height: 24),

            // 5. Inset Grouped List : Activité récente
            _buildSectionHeader('Activité récente', actionText: 'Tout afficher'),
            const SizedBox(height: 10),
            _buildRecentActivityList(),
            const SizedBox(height: 20),

            // 6. Section Équipe
            _buildTeamCard(),
            const SizedBox(height: 24),

            // 7. Bouton d'action principal iOS
            _buildActionButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Composants Internes ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MARDI 24 OCTOBRE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Tableau de bord',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _cardElevatedBg,
              child: Icon(Icons.person, color: _textSecondary),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bgSurface, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: _tertiary),
                    SizedBox(width: 6),
                    Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.cloud_done, size: 15, color: _tertiary),
                  SizedBox(width: 4),
                  Text(
                    'Supabase v2.4',
                    style: TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ravi de vous revoir, $name 👋',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Votre espace Supabase est synchronisé en temps réel avec Paris (eu-west-3).',
            style: TextStyle(fontSize: 14, color: _textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: _cardElevatedBg,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: Icon(Icons.sync, size: 16, color: _primary),
                label: Text(
                  'Rafraîchir les tables',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              Text(
                'Il y a 32s',
                style: TextStyle(fontSize: 11, color: _textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Projets actifs',
                value: '12',
                badgeText: '+12%',
                icon: Icons.folder,
                iconBg: _primaryContainer,
                iconColor: _primary,
                badgeBg: _tertiaryContainer,
                badgeTextColor: _tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Tâches bouclées',
                value: '28',
                badgeText: '+8%',
                icon: Icons.check_circle,
                iconBg: _tertiaryContainer,
                iconColor: _tertiary,
                badgeBg: _tertiaryContainer,
                badgeTextColor: _tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Messages non lus',
                value: '5',
                badgeText: 'Nouveau',
                icon: Icons.chat,
                iconBg: _errorContainer,
                iconColor: _error,
                badgeBg: _error,
                badgeTextColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Santé système',
                value: '98%',
                badgeText: 'Optimal',
                icon: Icons.speed,
                iconBg: _secondaryContainer,
                iconColor: _secondary,
                badgeBg: _secondaryContainer,
                badgeTextColor: _secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String badgeText,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    final days = [
      {'day': 'Lun', 'height': 56.0, 'highlight': false},
      {'day': 'Mar', 'height': 72.0, 'highlight': false},
      {'day': 'Mer', 'height': 48.0, 'highlight': false},
      {'day': 'Jeu', 'height': 96.0, 'highlight': true},
      {'day': 'Ven', 'height': 64.0, 'highlight': false},
      {'day': 'Sam', 'height': 40.0, 'highlight': false},
      {'day': 'Dim', 'height': 32.0, 'highlight': false},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Requêtes API & Latence',
                    style: TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '142,8 k ops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _cardElevatedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: _textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '7 derniers jours',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((data) {
                final isHighlight = data['highlight'] as bool;
                final barHeight = data['height'] as double;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isHighlight)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pic',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Container(
                      width: 16,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isHighlight ? _primary : _primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                        color: isHighlight ? _primary : _textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Divider(height: 24, color: _dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: _primary),
                  SizedBox(width: 6),
                  Text(
                    'Trafic moyen : 20,4k/j',
                    style: TextStyle(fontSize: 11, color: _textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 13, color: _tertiary),
                  Text(
                    '+18.4% vs s-1',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(
            title: 'Migration auth.users',
            subtitle: 'Schéma public mis à jour',
            time: '14:22',
            icon: Icons.rocket_launch,
            iconBg: _primaryContainer,
            iconColor: _primary,
          ),
          Divider(height: 1, indent: 56, color: _dividerColor),
          _buildActivityItem(
            title: 'Sauvegarde snapshot',
            subtitle: 'PostgreSQL 15.1 · 1.4 Go',
            time: '11:05',
            icon: Icons.dns,
            iconBg: _tertiaryContainer,
            iconColor: _tertiary,
          ),
          Divider(height: 1, indent: 56, color: _dividerColor),
          _buildActivityItem(
            title: 'Edge Function déclenchée',
            subtitle: 'send-welcome-push (31ms)',
            time: 'Hier',
            icon: Icons.bolt,
            iconBg: _secondaryContainer,
            iconColor: _secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: _textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 11, color: _textSecondary),
              ),
              const SizedBox(height: 2),
              Icon(Icons.chevron_right, size: 16, color: _outlineVariant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 32,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _cardElevatedBg,
                    ),
                    Positioned(
                      left: 14,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade800,
                      ),
                    ),
                    Positioned(
                      left: 28,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: _dividerColor,
                        child: Text(
                          '+3',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Équipe Core Dev',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    '5 membres actifs',
                    style: TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryContainer,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Inviter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
        label: const Text(
          'Créer une table ou un projet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}