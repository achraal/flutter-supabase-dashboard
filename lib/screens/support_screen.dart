import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryIndex;

  // --- DÉTECTION DU THÈME ---
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // --- PALETTE DE COULEURS DYNAMIQUE ---
  Color get _bgSurface => _darkMode ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get _cardBg => _darkMode ? const Color(0xFF1C1C1E) : Colors.white;
  Color get _cardElevatedBg => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  Color get _primary => const Color(0xFF0A84FF);
  Color get _primaryContainer => _darkMode ? const Color(0xFF003063) : const Color(0xFFE5F0FF);
  Color get _tertiary => const Color(0xFF30D158);
  Color get _tertiaryContainer => _darkMode ? const Color(0xFF0C3B18) : const Color(0xFFE8F8EB);
  Color get _secondary => const Color(0xFF5E5CE6);
  Color get _secondaryContainer => _darkMode ? const Color(0xFF252361) : const Color(0xFFEBEBFA);
  Color get _error => const Color(0xFFFF453A);
  Color get _errorContainer => _darkMode ? const Color(0xFF4A100D) : const Color(0xFFFFEBEA);

  Color get _textPrimary => _darkMode ? Colors.white : Colors.black;
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _outline => _darkMode ? const Color(0xFF636366) : const Color(0xFF8E8E93);
  Color get _outlineVariant => _darkMode ? const Color(0xFF48484A) : const Color(0xFFD1D1D6);
  Color get _hairlineColor => _darkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

  // --- Données de la FAQ ---
  List<_FaqItem> get _faqItems => [
    _FaqItem(
      question: 'Comment réinitialiser mon mot de passe ?',
      answer:
      'Accédez à la page de connexion et cliquez sur "Mot de passe oublié". Un lien sécurisé de réinitialisation vous sera envoyé par e-mail via Supabase Auth.',
      category: 'Compte',
      icon: Icons.lock_reset,
      iconBg: _primaryContainer,
      iconColor: _primary,
    ),
    _FaqItem(
      question: 'Comment configurer les règles RLS Postgres ?',
      answer:
      'Rendez-vous dans la section Sécurité de vos réglages ou dans le Dashboard Supabase. Activez la Row Level Security (RLS) sur vos tables publiques pour restreindre l\'accès selon les identifiants utilisateurs.',
      category: 'Sécurité',
      icon: Icons.shield,
      iconBg: _errorContainer,
      iconColor: _error,
    ),
    _FaqItem(
      question: 'Comment vider le cache et resynchroniser les tables ?',
      answer:
      'Allez dans "Réglages" > "Données & Cache" puis appuyez sur "Vider le cache". Vous pouvez également utiliser le bouton de rafraîchissement sur le Tableau de Bord.',
      category: 'Données',
      icon: Icons.cleaning_services,
      iconBg: _secondaryContainer,
      iconColor: _secondary,
    ),
    _FaqItem(
      question: 'Où trouver les clés API et le jeton JWT ?',
      answer:
      'Vos clés publiques (anon key) et vos jetons de session sont accessibles dans votre profil sous l\'onglet "Supabase & Infrastructure".',
      category: 'Compte',
      icon: Icons.key,
      iconBg: _tertiaryContainer,
      iconColor: _tertiary,
    ),
    _FaqItem(
      question: 'La synchronisation hors-ligne ne fonctionne pas ?',
      answer:
      'Vérifiez que l\'option "Synchronisation hors-ligne" est bien activée dans vos réglages. La base local SQLite se resynchronisera automatiquement dès qu\'une connexion sera détectée.',
      category: 'Données',
      icon: Icons.sync_problem,
      iconBg: _primaryContainer,
      iconColor: _primary,
    ),
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Tout', 'icon': Icons.all_inclusive},
    {'label': 'Compte', 'icon': Icons.person},
    {'label': 'Sécurité', 'icon': Icons.security},
    {'label': 'Données', 'icon': Icons.storage},
  ];

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

  List<_FaqItem> get _filteredFaq {
    return _faqItems.where((item) {
      final matchesSearch = item.question.toLowerCase().contains(_searchQuery) ||
          item.answer.toLowerCase().contains(_searchQuery);

      if (_selectedCategoryIndex == null || _selectedCategoryIndex == 0) {
        return matchesSearch;
      }

      final categoryLabel = _categories[_selectedCategoryIndex!]['label'] as String;
      return matchesSearch && item.category == categoryLabel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredFaq;

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. En-tête : Titre Large iOS & Statut Support
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aide & Support',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
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
                        'Support 24/7',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _tertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Barre de Recherche Native iOS Dark
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: TextStyle(fontSize: 15, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher une question, une erreur...',
                  hintStyle: TextStyle(color: _outline, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: _outline, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.cancel, color: _outline, size: 18),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Catégories sous forme de Chips Horizontaux
            SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = (_selectedCategoryIndex ?? 0) == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      showCheckmark: false,
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : _textSecondary,
                      ),
                      label: Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : _textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _primary,
                      backgroundColor: _cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryIndex = selected ? index : 0;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 4. Section FAQ / Cartes Accordéon Groupées
            _buildSectionTitle('FOIRE AUX QUESTIONS'),
            const SizedBox(height: 8),

            if (filteredList.isEmpty)
              _buildEmptyState()
            else
              _buildGroupedFaqCard(filteredList),

            const SizedBox(height: 24),

            // 5. Section : ASSISTANCE DIRECTE & CANAUX
            _buildSectionTitle('CONTACTER L\'ASSISTANCE'),
            const SizedBox(height: 8),
            _buildGroupedCard([
              _buildContactRow(
                icon: Icons.headset_mic,
                iconBg: _primaryContainer,
                iconColor: _primary,
                title: 'Chat avec le support Supabase',
                subtitle: 'Temps de réponse moyen : 5 min',
                onTap: () {
                  _showToast('Connexion au support en direct...', Icons.chat);
                },
              ),
              _buildContactRow(
                icon: Icons.mark_email_read,
                iconBg: _secondaryContainer,
                iconColor: _secondary,
                title: 'Envoyer un e-mail',
                subtitle: 'support@supabase.io',
                onTap: () {
                  _showToast('Application e-mail ouverte', Icons.email);
                },
              ),
              _buildContactRow(
                icon: Icons.menu_book,
                iconBg: _tertiaryContainer,
                iconColor: _tertiary,
                title: 'Documentation API & Guides',
                subtitle: 'Consulter docs.supabase.com',
                onTap: () {
                  _showToast('Redirection vers la documentation', Icons.open_in_browser);
                },
              ),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Composants d'interface réutilisables ---

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

  Widget _buildGroupedFaqCard(List<_FaqItem> items) {
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
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Column(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.only(left: 56, right: 16, bottom: 16),
                    iconColor: _outline,
                    collapsedIconColor: _outline,
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 17),
                    ),
                    title: Text(
                      item.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    children: [
                      Text(
                        item.answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < items.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: 56.0),
                    child: Divider(height: 0.5, thickness: 0.5, color: _hairlineColor),
                  ),
              ],
            );
          }).toList(),
        ),
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

  Widget _buildContactRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _outlineVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 36, color: _outline),
          SizedBox(height: 8),
          Text(
            'Aucune question trouvée',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Essayez de modifier vos termes de recherche ou sélectionnez une autre catégorie.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Modèle d'élément FAQ ---
class _FaqItem {
  final String question;
  final String answer;
  final String category;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}