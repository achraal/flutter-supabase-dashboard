import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login_page.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic>? profile; // AJOUT
  const SettingsScreen({super.key, this.profile}); // MODIFICATION

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // États des réglages
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;
  bool _pushNotifications = true;
  bool _biometrics = true;
  bool _offlineSync = true;
  bool _isClearingCache = false;
  double _cacheSizeMb = 24.0;

  // --- PALETTE DE COULEURS DYNAMIQUE (Dark Mode iOS & Light Mode Fallback) ---
  Color get _bgSurface => _darkMode ? const Color(0xFF000000) : const Color(0xFFFAF9FE);
  Color get _cardBg => _darkMode ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _cardElevatedBg => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF4F3F8);
  Color get _textPrimary => _darkMode ? Colors.white : const Color(0xFF1A1B1F);
  Color get _textSecondary => _darkMode ? const Color(0xFF8E8E93) : const Color(0xFF414755);
  Color get _outline => _darkMode ? const Color(0xFF636366) : const Color(0xFF717786);
  Color get _outlineVariant => _darkMode ? const Color(0xFF48484A) : const Color(0xFFC1C6D7);
  Color get _hairlineColor => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE9E7ED);
  Color get _searchBg => _darkMode ? const Color(0xFF1C1C1E) : const Color(0xFFE3E2E7).withOpacity(0.6);

  // Couleurs d'accentuation iOS Dark Mode
  static const Color _primary = Color(0xFF0A84FF); // Blue iOS Dark
  static const Color _secondary = Color(0xFF5E5CE6); // Purple/Indigo iOS Dark
  static const Color _tertiary = Color(0xFF30D158); // Green iOS Dark
  static const Color _error = Color(0xFFFF453A); // Red iOS Dark
  static const Color _warning = Color(0xFFFF9F0A); // Orange iOS Dark

  void _showToast(String message, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFF2F3034),
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

  void _clearCache() async {
    setState(() => _isClearingCache = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _cacheSizeMb = 0.0;
      _isClearingCache = false;
    });
    _showToast('Cache vidé : 24 Mo libérés', Icons.cleaning_services);
  }

  bool _matches(List<String> keywords) {
    if (_searchQuery.isEmpty) return true;
    return keywords.any((k) => k.toLowerCase().contains(_searchQuery) || _searchQuery.contains(k.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = widget.profile?['name'] ?? widget.profile?['full_name'] ?? 'Alexandre Martin';
    final userEmail = user?.email ?? widget.profile?['email'] ?? 'Identifiant non trouvé';
    final avatarUrl = widget.profile?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Titre Large iOS & Sync Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réglages',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _cardBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sync, color: _primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Barre de recherche natif iOS Dark Mode
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: _searchBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: TextStyle(fontSize: 15, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  hintStyle: TextStyle(color: _outline, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: _outline, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.cancel, color: _outline, size: 18),
                  )
                      : Icon(Icons.mic, color: _outline, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Fiche Profil / Identifiant Apple
            if (_matches(['profil', 'alexandre', 'compte', 'sécurité', 'email', userEmail])) ...[
              _buildProfileCard(userName, userEmail, avatarUrl),
              const SizedBox(height: 20),
            ],

            // 4. SECTION: PRÉFÉRENCES
            if (_matches(['mode sombre', 'notifications', 'langue', 'préférences'])) ...[
              _buildSectionTitle('PRÉFÉRENCES'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                if (_matches(['mode sombre']))
                  _buildSwitchRow(
                    icon: Icons.dark_mode,
                    iconBg: _secondary,
                    iconColor: Colors.white,
                    title: 'Mode sombre',
                    value: _darkMode,
                    onChanged: (val) {
                      globalDarkMode.value = val;
                      _showToast(val ? 'Mode sombre activé' : 'Mode clair activé', Icons.dark_mode);
                    },
                  ),
                if (_matches(['notifications']))
                  _buildSwitchRow(
                    icon: Icons.notifications_active,
                    iconBg: _error,
                    iconColor: Colors.white,
                    title: 'Notifications push',
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() => _pushNotifications = val);
                      _showToast(val ? 'Notifications activées' : 'Notifications désactivées', Icons.notifications);
                    },
                  ),
                if (_matches(['langue']))
                  _buildNavigationRow(
                    icon: Icons.language,
                    iconBg: _primary,
                    iconColor: Colors.white,
                    title: 'Langue',
                    trailingText: 'Français (FR)',
                    onTap: () {},
                  ),
              ]),
              const SizedBox(height: 20),
            ],

            // 5. SECTION: SÉCURITÉ & AUTH
            if (_matches(['mot de passe', 'face id', 'touch id', 'appareils', '2fa', 'double authentification', 'sécurité'])) ...[
              _buildSectionTitle('SÉCURITÉ & AUTH'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                if (_matches(['mot de passe']))
                  _buildNavigationRow(
                    icon: Icons.key,
                    iconBg: _outline,
                    iconColor: Colors.white,
                    title: 'Changer le mot de passe',
                    onTap: () {},
                  ),
                if (_matches(['face id', 'touch id', 'biométrie']))
                  _buildSwitchRow(
                    icon: Icons.fingerprint,
                    iconBg: _tertiary,
                    iconColor: Colors.white,
                    title: 'Face ID / Touch ID',
                    value: _biometrics,
                    onChanged: (val) {
                      setState(() => _biometrics = val);
                      _showToast(val ? 'Biométrie activée' : 'Biométrie désactivée', Icons.fingerprint);
                    },
                  ),
                if (_matches(['appareils', 'sessions']))
                  _buildNavigationRow(
                    icon: Icons.devices,
                    iconBg: _warning,
                    iconColor: Colors.white,
                    title: 'Appareils connectés',
                    trailingText: '2 actifs',
                    onTap: () {},
                  ),
                if (_matches(['2fa', 'double authentification']))
                  _buildNavigationRow(
                    icon: Icons.verified_user,
                    iconBg: _primary,
                    iconColor: Colors.white,
                    title: 'Double authentification',
                    badge: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tertiary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Activé',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _tertiary),
                      ),
                    ),
                    onTap: () {},
                  ),
              ]),
              const SizedBox(height: 20),
            ],

            // 6. SECTION: DONNÉES & CACHE
            if (_matches(['synchronisation', 'cache', 'stockage', 'données'])) ...[
              _buildSectionTitle('DONNÉES & CACHE'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                if (_matches(['synchronisation']))
                  _buildSwitchRow(
                    icon: Icons.cloud_sync,
                    iconBg: _secondary,
                    iconColor: Colors.white,
                    title: 'Synchronisation hors-ligne',
                    value: _offlineSync,
                    onChanged: (val) {
                      setState(() => _offlineSync = val);
                      _showToast(val ? 'Synchro activée' : 'Synchro désactivée', Icons.sync);
                    },
                  ),
                if (_matches(['cache']))
                  _buildCustomRow(
                    icon: Icons.cleaning_services,
                    iconBg: _outlineVariant,
                    iconColor: Colors.white,
                    title: 'Vider le cache',
                    trailing: TextButton(
                      onPressed: _cacheSizeMb == 0 || _isClearingCache ? null : _clearCache,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: _isClearingCache
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
                      )
                          : Text(
                        _cacheSizeMb == 0 ? 'Effacé (0 Ko)' : 'Effacer (${_cacheSizeMb.toStringAsFixed(0)} Mo)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _cacheSizeMb == 0 ? _outline : _primary,
                        ),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 24),
            ],

            // 7. ACTION DESTRUCTRICE ISOLÉE
            _buildDeleteAccountButton(),
            const SizedBox(height: 8),

            Text(
              'Cette action supprimera définitivement vos clés d\'API et instances locales.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _outline),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Composants d'interface réutilisables iOS ---

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

  Widget _buildProfileCard(String name, String email, String? avatarUrl) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _cardElevatedBg,
                      // AJOUT : Image de fond si l'URL existe
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      // AJOUT : Icône par défaut si pas d'image
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(Icons.person, color: _textSecondary, size: 30)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(color: _cardBg, width: 2),
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Compte vérifié Supabase',
                        style: TextStyle(fontSize: 13, color: _textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email.contains('@') ? email : 'Identifiant, mot de passe et sécurité',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _outlineVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    final validChildren = children.where((w) => w is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < validChildren.length; i++) {
      itemsWithDividers.add(validChildren[i]);
      if (i < validChildren.length - 1) {
        itemsWithDividers.add(
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
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
            color: Colors.black.withOpacity(_darkMode ? 0.3 : 0.05),
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

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          _buildSquareIcon(icon, iconBg, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: _textPrimary),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: _tertiary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? trailingText,
    Widget? badge,
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
                  style: TextStyle(fontSize: 16, color: _textPrimary),
                ),
              ),
              if (badge != null) badge,
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(fontSize: 15, color: _outline),
                ),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right, color: _outlineVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildSquareIcon(icon, iconBg, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: _textPrimary),
            ),
          ),
          trailing,
        ],
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

  Widget _buildDeleteAccountButton() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: _cardBg,
                title: Text('Confirmer la suppression ?', style: TextStyle(color: _textPrimary)),
                content: Text(
                  'Cette action est irréversible et supprimera vos instances locales et jetons Supabase.',
                  style: TextStyle(color: _textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Annuler', style: TextStyle(color: _outline)),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      }
                    },
                    child: const Text('Supprimer', style: TextStyle(color: _error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Center(
              child: Text(
                'Supprimer mon compte',
                style: TextStyle(
                  fontSize: 17,
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