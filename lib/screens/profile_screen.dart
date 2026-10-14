import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? profile;

  const ProfileScreen({super.key, this.user, this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- DÉTECTION DU THÈME ---
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // --- PALETTE DE COULEURS DYNAMIQUE (Dark & Light) ---
  Color get _bgSurface => _darkMode ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get _cardBg => _darkMode ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _cardElevatedBg => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  // Accents iOS
  Color get _primary => const Color(0xFF0A84FF);
  Color get _primaryContainer => _darkMode ? const Color(0xFF003063) : const Color(0xFFE5F0FF);

  Color get _tertiary => const Color(0xFF30D158);
  Color get _tertiaryContainer => _darkMode ? const Color(0xFF0C3B18) : const Color(0xFFE8F8EB);

  Color get _secondary => const Color(0xFF5E5CE6);
  Color get _secondaryContainer => _darkMode ? const Color(0xFF252361) : const Color(0xFFEBEBFA);

  Color get _error => const Color(0xFFFF453A);

  // Textes & Lignes
  Color get _textPrimary => _darkMode ? Colors.white : Colors.black;
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _outline => const Color(0xFF636366);
  Color get _outlineVariant => _darkMode ? const Color(0xFF48484A) : const Color(0xFFD1D1D6);
  Color get _hairlineColor => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  bool _isEditing = false;

  void _showToast(String message, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
    final name = widget.profile?['name'] ?? widget.profile?['full_name'] ?? "Non renseigné";
    final phone = widget.profile?['phone'] ?? "Non renseigné";
    final avatarUrl = widget.profile?['avatar_url'] as String?;
    final email = widget.user?.email ?? 'Non renseigné';
    final role = widget.profile?['role'] ?? 'Elève ingénieur Full-Stack';

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. En-tête : Titre Large iOS & Action Modifier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mon Profil',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isEditing = !_isEditing);
                    _showToast(
                      _isEditing ? 'Mode édition activé' : 'Profil enregistré',
                      _isEditing ? Icons.edit : Icons.check_circle,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isEditing ? _primary : _cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isEditing ? 'Terminer' : 'Éditer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isEditing ? Colors.white : _primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Fiche d'identité / Avatar iOS
            _buildProfileCard(
              name: name,
              email: email,
              role: role,
              avatarUrl: avatarUrl,
            ),
            const SizedBox(height: 20),

            // 3. Mini Dashboard Stats Profil
            _buildStatsRow(),
            const SizedBox(height: 20),

            // 4. Section : COORDONNÉES & CONTACT
            _buildSectionTitle('INFORMATIONS DE CONTACT'),
            const SizedBox(height: 6),
            _buildGroupedCard([
              _buildInfoRow(
                icon: Icons.phone_iphone,
                iconBg: _primaryContainer,
                iconColor: _primary,
                title: 'Téléphone',
                value: phone,
              ),
              _buildInfoRow(
                icon: Icons.alternate_email,
                iconBg: _secondaryContainer,
                iconColor: _secondary,
                title: 'Email',
                value: email,
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Vérifié',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _tertiary),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // 5. Section : COMPTE & CLOUD
            _buildSectionTitle('SUPABASE & INFRASTRUCTURE'),
            const SizedBox(height: 6),
            _buildGroupedCard([
              _buildNavigationRow(
                icon: Icons.badge,
                iconBg: _secondaryContainer,
                iconColor: _secondary,
                title: 'ID Utilisateur',
                trailingText: widget.user?.id != null
                    ? '${widget.user!.id.substring(0, 8)}...'
                    : 'UUID indisponible',
                onTap: () {
                  _showToast('ID copié dans le presse-papier', Icons.copy);
                },
              ),
              _buildNavigationRow(
                icon: Icons.cloud_done,
                iconBg: _tertiaryContainer,
                iconColor: _tertiary,
                title: 'Projet Supabase',
                trailingText: 'eu-west-3 (Paris)',
                onTap: () {},
              ),
              _buildNavigationRow(
                icon: Icons.lock_person,
                iconBg: const Color(0xFF4A100D),
                iconColor: _error,
                title: 'Rôle RLS Postgres',
                trailingText: 'authenticated',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // 6. Actions de déconnexion
            _buildSignOutButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // --- Composants d'interface ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _outline,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
    required String role,
    required String? avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: _cardElevatedBg,
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 48, color: _textSecondary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: _cardBg, width: 2.5),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 13, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Projets', '12', Icons.folder, _primaryContainer, _primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem('API Calls', '142k', Icons.bolt, _secondaryContainer, _secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem('Statut', 'En ligne', Icons.circle, _tertiaryContainer, _tertiary),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String val, IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: _outline),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      itemsWithDividers.add(children[i]);
      if (i < children.length - 1) {
        itemsWithDividers.add(
          Padding(
            padding: EdgeInsets.only(left: 56.0),
            child: Divider(height: 0.5, thickness: 0.5, color: _hairlineColor),
          ),
        );
      }
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: itemsWithDividers),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    Widget? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildSquareIcon(icon, iconBg, iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: _outline),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
              ),
            ],
          ),
          const Spacer(),
          if (badge != null) badge,
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              _buildSquareIcon(icon, iconBg, iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, color: _textPrimary),
                ),
              ),
              Text(
                trailingText,
                style: TextStyle(fontSize: 14, color: _outline),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: _outlineVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareIcon(IconData icon, Color bg, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }

  Widget _buildSignOutButton() {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Supabase.instance.client.auth.signOut();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Center(
              child: Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}