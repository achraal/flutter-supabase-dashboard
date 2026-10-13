import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // --- PALETTE DE COULEURS EN MODE SOMBRE (iOS Dark Mode OLED) ---
  static const Color _bgSurface = Color(0xFF000000); // Pure Black OLED
  static const Color _cardBg = Color(0xFF1C1C1E); // Elevated Dark Card
  static const Color _cardElevatedBg = Color(0xFF2C2C2E); // Segment & Inner Containers

  // Accents iOS System Dark
  static const Color _primary = Color(0xFF0A84FF); // Blue iOS Dark
  static const Color _primaryContainer = Color(0xFF003063);
  static const Color _tertiary = Color(0xFF30D158); // Green iOS Dark
  static const Color _tertiaryContainer = Color(0xFF0C3B18);
  static const Color _secondary = Color(0xFF5E5CE6); // Purple/Indigo iOS Dark
  static const Color _secondaryContainer = Color(0xFF252361);
  static const Color _error = Color(0xFFFF453A); // Red iOS Dark
  static const Color _errorContainer = Color(0xFF4A100D);

  // Textes & Neutral Colors
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _outline = Color(0xFF636366);

  // --- Gestion des états ---
  int _selectedTabIndex = 0; // 0: Toutes, 1: Non lues, 2: Système
  bool _keepArchives = true;

  late List<_NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _NotificationModel(
        id: '1',
        title: "Bienvenue sur l'application !",
        description: "Votre compte Supabase est initialisé et prêt.",
        time: '10:42',
        isUnread: true,
        isSystem: false,
        icon: Icons.rocket_launch,
        iconBg: _primaryContainer,
        iconColor: _primary,
        tagText: 'Connecté',
        projectTag: 'Projet lié : dev_cloud',
      ),
      _NotificationModel(
        id: '2',
        title: 'Mise à jour de sécurité',
        description: 'Règles RLS Postgres appliquées avec succès pour vos tables publiques.',
        time: 'Il y a 2 h',
        isUnread: true,
        isSystem: true,
        icon: Icons.shield,
        iconBg: _errorContainer,
        iconColor: _error,
        actionLinkText: "Vérifier l'audit RLS",
      ),
      _NotificationModel(
        id: '3',
        title: 'Conseil Flutter & Supabase',
        description: 'Activez la réplication en temps réel pour synchroniser les changements instantanément.',
        time: 'Hier',
        isUnread: true,
        isSystem: false,
        icon: Icons.lightbulb,
        iconBg: _secondaryContainer,
        iconColor: _secondary,
      ),
      _NotificationModel(
        id: '4',
        title: 'Sauvegarde automatique',
        description: 'Snapshot quotidien de votre instance Postgres complété sans incident (24,8 Mo).',
        time: 'Il y a 3 j',
        isUnread: false,
        isSystem: true,
        icon: Icons.storage,
        iconBg: _cardElevatedBg,
        iconColor: _textSecondary,
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  List<_NotificationModel> get _filteredNotifications {
    if (_selectedTabIndex == 1) {
      return _notifications.where((n) => n.isUnread).toList();
    } else if (_selectedTabIndex == 2) {
      return _notifications.where((n) => n.isSystem).toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isUnread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredNotifications;

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. En-tête : Titre, Badge & Bouton "Tout lire"
            _buildHeader(),
            const SizedBox(height: 16),

            // 2. Segmented Control style iOS
            _buildSegmentedControl(),
            const SizedBox(height: 16),

            // 3. Liste des notifications ou état vide
            if (filteredList.isEmpty)
              _buildEmptyState()
            else
              ...filteredList.map((notif) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildNotificationCard(notif),
              )),

            const SizedBox(height: 24),

            // 4. Section Archiver & Footnote
            _buildArchiveSection(),
            const SizedBox(height: 20),

            // 5. Bouton d'action rapide principal
            _buildQuickActionButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Composants d'interface ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        TextButton(
          onPressed: _unreadCount > 0 ? _markAllAsRead : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Tout lire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _unreadCount > 0 ? _primary : _outline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              // Curseur animé iOS Dark Mode
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _selectedTabIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardElevatedBg,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Boutons de navigation
              Row(
                children: [
                  _buildSegmentButton(0, 'Toutes', tabWidth),
                  _buildSegmentButton(1, 'Non lues ($_unreadCount)', tabWidth),
                  _buildSegmentButton(2, 'Système', tabWidth),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentButton(int index, String title, double width) {
    final isSelected = _selectedTabIndex == index;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(9),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? _textPrimary : _textSecondary,
              fontFamily: 'Inter',
            ),
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationModel item) {
    return Opacity(
      opacity: item.isUnread ? 1.0 : 0.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône avec badge de non-lecture
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 24),
                ),
                if (item.isUnread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: _cardBg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Contenu de la notification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.tagText != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.tagText!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.3,
                    ),
                  ),

                  // Tag Projet contextuel
                  if (item.projectTag != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _cardElevatedBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 14, color: _tertiary),
                          const SizedBox(width: 4),
                          Text(
                            item.projectTag!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Lien d'action RLS / Audit
                  if (item.actionLinkText != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.actionLinkText!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward,
                              size: 14, color: _primary),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_paused,
                size: 32, color: _outline),
          ),
          const SizedBox(height: 12),
          const Text(
            'Toutes les notifications sont lues',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vous êtes parfaitement à jour avec vos événements et les déclencheurs Supabase.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _cardElevatedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2,
                        size: 20, color: _outline),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Conserver les archives',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Suppression automatique après 30 jours',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _keepArchives,
                activeColor: _tertiary,
                onChanged: (val) => setState(() => _keepArchives = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Les notifications prioritaires sont envoyées en direct depuis votre client Flutter via les webhooks Supabase Edge Functions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _outline,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _markAllAsRead,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
        label: const Text(
          'Marquer tout comme traité',
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

// --- Modèle de données Helper ---
class _NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  bool isUnread;
  final bool isSystem;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? tagText;
  final String? projectTag;
  final String? actionLinkText;

  _NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    required this.isSystem,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.tagText,
    this.projectTag,
    this.actionLinkText,
  });
}