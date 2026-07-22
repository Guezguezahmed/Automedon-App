import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _roleLabel(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return 'Administrateur';
    case 'sub_office':
      return 'Sous-agence';
    case 'assistant':
      return 'Assistant';
    case 'user':
      return 'Utilisateur';
    default:
      return role;
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'Actif';
    case 'suspended':
      return 'Suspendu';
    default:
      return status;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Obsidian Design System Tokens
// ─────────────────────────────────────────────────────────────────────────────

class _DarkTokens {
  static const Color bgDark = Color(0xFF0A071B);
  static const Color cardDark = Color(0xFF140F2D);

  static const Color neonViolet = Color(0xFF7C6FEA);
  static const Color neonBlue = Color(0xFF3B82F6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonMint = Color(0xFF10B981);
  static const Color neonPink = Color(0xFFEC4899);

  static const List<Color> heroGradient = [
    Color(0xFF2E1A72),
    Color(0xFF180E43),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  ProfileScreen — Dark Glass Telemetry Deck
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = const ['Tous', 'Mon agence', 'Flotte', 'Contrats', 'Services'];

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      backgroundColor: _DarkTokens.bgDark,
      body: meAsync.when(
        loading: () => const _ProfileSkeletonDark(),
        error: (err, _) => _ProfileErrorDark(
          message: err.toString(),
          onRetry: () => ref.invalidate(meProvider),
        ),
        data: (data) {
          final user = data['user'] as Map<String, dynamic>;
          final tenant = data['tenant'] as Map<String, dynamic>;

          final username = user['username'] as String? ?? '—';
          final role = user['role'] as String? ?? 'user';
          final tenantName = tenant['name'] as String? ?? '—';
          final tenantSlug = tenant['slug'] as String? ?? '—';
          final status = tenant['status'] as String? ?? 'active';
          final logoUrl = tenant['logo_url'] as String?;

          return Stack(
            children: [
              // Ambient gradient mesh background orbs
              Positioned(
                top: -80,
                right: -40,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _DarkTokens.neonViolet.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _DarkTokens.neonBlue.withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Scroll Content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top App Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: _buildTopHeader(username, role, logoUrl),
                      ),
                    ),

                    // Big Title: Overview of your activities
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Aperçu de vos\nactivités',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Filter Pills Row
                    SliverToBoxAdapter(
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filters.length,
                          itemBuilder: (context, i) {
                            final isSelected = _selectedFilterIndex == i;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedFilterIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : _DarkTokens.cardDark.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _filters[i],
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? _DarkTokens.bgDark : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Hero Agency Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: _buildHeroAgencyCard(tenantName, tenantSlug, status),
                      ),
                    ),

                    // Bento Grid Row: Productivity Chart + Premium/Stats Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Bento: Weekly Productivity Chart
                            Expanded(
                              flex: 6,
                              child: _buildWeeklyProductivityCard(),
                            ),
                            const SizedBox(width: 12),
                            // Right Bento: Agency Status & Upgrade Card
                            Expanded(
                              flex: 5,
                              child: _buildAgencyQuickCard(tenantName, status),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Navigation Grid Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          'Modules & Services',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Navigation Grid Menu Items
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.settings_outlined,
                            title: 'Mon agence',
                            subtitle: tenantName,
                            color: _DarkTokens.neonViolet,
                            route: '/monagence',
                          ),
                          const SizedBox(height: 10),
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.description_outlined,
                            title: 'Leasing',
                            subtitle: 'Contrats & échéances',
                            color: _DarkTokens.neonBlue,
                            route: '/leasing',
                          ),
                          const SizedBox(height: 10),
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.directions_car_outlined,
                            title: 'Gestion Flotte',
                            subtitle: 'Détails du parc',
                            color: _DarkTokens.neonMint,
                            route: '/gestion_flotte',
                          ),
                          const SizedBox(height: 10),
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.star_outlined,
                            title: 'Services',
                            subtitle: 'Services additionnels',
                            color: _DarkTokens.neonPink,
                            route: '/services',
                          ),
                          const SizedBox(height: 10),
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.trending_up,
                            title: 'Historique',
                            subtitle: 'Journal d\'activité',
                            color: const Color(0xFFA855F7),
                            route: '/historique',
                          ),
                          const SizedBox(height: 10),
                          _buildDarkMenuItem(
                            context,
                            icon: Icons.warning_amber_rounded,
                            title: 'Signalements',
                            subtitle: 'Liste noire clients',
                            color: const Color(0xFFF43F5E),
                            route: '/signalements',
                          ),
                          const SizedBox(height: 16),

                          // Toggles
                          const _DarkThemeToggle(),
                          const SizedBox(height: 10),
                          const _DarkNotificationsToggle(),
                          const SizedBox(height: 10),
                          const _DarkLanguageToggle(),
                          const SizedBox(height: 16),

                          // Account Info Card
                          _DarkUserInfoCard(
                            username: username,
                            role: role,
                            tenantName: tenantName,
                            tenantSlug: tenantSlug,
                            status: status,
                          ),
                          const SizedBox(height: 16),

                          // Logout Button
                          const _DarkLogoutButton(),

                          const SizedBox(height: 140),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Top header: avatar + greeting + actions
  Widget _buildTopHeader(String username, String role, String? logoUrl) {
    final initials = username.trim().isNotEmpty
        ? username.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _DarkTokens.neonViolet.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            image: logoUrl != null
                ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: logoUrl == null
              ? Text(
                  initials,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'Compte ${_roleLabel(role)}',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_DarkTokens.neonViolet, _DarkTokens.neonBlue],
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // Hero Card matching reference design card
  Widget _buildHeroAgencyCard(String tenantName, String tenantSlug, String status) {
    final isActive = status.toLowerCase() == 'active';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _DarkTokens.heroGradient,
        ),
        border: Border.all(
          color: _DarkTokens.neonViolet.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _DarkTokens.neonViolet.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _DarkTokens.neonBlue,
                      _DarkTokens.neonViolet,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Actif • Premium' : _statusLabel(status),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'ID: $tenantSlug',
                  style: GoogleFonts.courierPrime(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Agency title
          Text(
            tenantName,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestion de la flotte et contrats de location',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Bottom bar: stacked badges + details button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _DarkTokens.neonCyan.withValues(alpha: 0.4),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 14),
                  ),
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _DarkTokens.neonViolet.withValues(alpha: 0.5),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(Icons.description, color: Colors.white, size: 14),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Opérationnel',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/monagence'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _DarkTokens.bgDark,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Détails',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Left Bento Card: Glowing Weekly Productivity Bar Chart
  Widget _buildWeeklyProductivityCard() {
    final days = const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final heights = const [0.4, 0.7, 1.0, 0.5, 0.85, 0.6, 0.45];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DarkTokens.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activité Flotte',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            'Hebdomadaire',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (index) {
                final heightFactor = heights[index];
                final isHighlight = index == 2; // Middle day glow highlight

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: 60 * heightFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isHighlight
                              ? [_DarkTokens.neonPink, _DarkTokens.neonViolet]
                              : [_DarkTokens.neonCyan, _DarkTokens.neonBlue],
                        ),
                        boxShadow: isHighlight
                            ? [
                                BoxShadow(
                                  color: _DarkTokens.neonPink.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.topCenter,
                      child: isHighlight
                          ? Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: GoogleFonts.inter(
                        color: isHighlight ? Colors.white : Colors.white38,
                        fontSize: 10,
                        fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Right Bento Card: Electric Blue Upgrade / Stats Card
  Widget _buildAgencyQuickCard(String tenantName, String status) {
    return Consumer(
      builder: (context, ref, child) {
        final carsAsync = ref.watch(carsProvider(null));
        final carCount = carsAsync.when(
          data: (d) => (d['cars'] as List?)?.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _DarkTokens.neonBlue.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Direct Flotte',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Voitures',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$carCount',
                    style: GoogleFonts.courierPrime(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'unités',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Capacité disponible',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  // Dark Neon Menu Items
  Widget _buildDarkMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _DarkTokens.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Notifications Toggle
// ─────────────────────────────────────────────────────────────────────────────

class _DarkNotificationsToggle extends ConsumerWidget {
  const _DarkNotificationsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DarkTokens.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _DarkTokens.neonViolet.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.notifications_outlined, color: _DarkTokens.neonViolet, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  enabled ? 'Activées' : 'Désactivées',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).toggle(v),
            activeThumbColor: _DarkTokens.neonViolet,
            activeTrackColor: _DarkTokens.neonViolet.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Language Toggle
// ─────────────────────────────────────────────────────────────────────────────

class _DarkLanguageToggle extends ConsumerWidget {
  const _DarkLanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(selectedLanguageProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _DarkTokens.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _DarkTokens.neonMint.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.language, color: _DarkTokens.neonMint, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langue',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Interface de l\'application',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DarkLangChip(
                  label: 'FR',
                  selected: lang == 'FR',
                  onTap: () => ref.read(selectedLanguageProvider.notifier).select('FR'),
                ),
                _DarkLangChip(
                  label: 'AR',
                  selected: lang == 'AR',
                  onTap: () => ref.read(selectedLanguageProvider.notifier).select('AR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkLangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DarkLangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _DarkTokens.neonViolet : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark User Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _DarkUserInfoCard extends StatelessWidget {
  final String username;
  final String role;
  final String tenantName;
  final String tenantSlug;
  final String status;

  const _DarkUserInfoCard({
    required this.username,
    required this.role,
    required this.tenantName,
    required this.tenantSlug,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DarkTokens.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'Informations du compte',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          _DarkInfoRow(icon: Icons.person_outline, label: 'Utilisateur', value: username),
          const Divider(height: 1, color: Colors.white10),
          _DarkInfoRow(icon: Icons.shield_outlined, label: 'Rôle', value: _roleLabel(role)),
          const Divider(height: 1, color: Colors.white10),
          _DarkInfoRow(icon: Icons.storefront_outlined, label: 'Agence', value: tenantName),
          const Divider(height: 1, color: Colors.white10),
          _DarkInfoRow(icon: Icons.badge_outlined, label: 'Identifiant', value: tenantSlug, isMono: true),
          const Divider(height: 1, color: Colors.white10),
          _DarkInfoRow(
            icon: Icons.verified_outlined,
            label: 'Statut',
            value: _statusLabel(status),
            valueColor: status.toLowerCase() == 'active' ? _DarkTokens.neonMint : const Color(0xFFF43F5E),
          ),
        ],
      ),
    );
  }
}

class _DarkInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMono;

  const _DarkInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: isMono
                ? GoogleFonts.courierPrime(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  )
                : GoogleFonts.inter(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Logout Button
// ─────────────────────────────────────────────────────────────────────────────

class _DarkLogoutButton extends ConsumerWidget {
  const _DarkLogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: _DarkTokens.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white10),
              ),
              title: Text('Déconnexion', style: GoogleFonts.outfit(color: Colors.white)),
              content: Text('Voulez-vous vraiment vous déconnecter ?', style: GoogleFonts.inter(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Annuler', style: GoogleFonts.inter(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Déconnexion',
                    style: GoogleFonts.inter(color: const Color(0xFFF43F5E), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true) {
            ref.read(authProvider.notifier).logout();
          }
        },
        icon: const Icon(Icons.logout, size: 18),
        label: Text(
          'Déconnexion',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
          backgroundColor: const Color(0xFFF43F5E).withValues(alpha: 0.08),
          foregroundColor: const Color(0xFFF43F5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Skeleton & Error State
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSkeletonDark extends StatelessWidget {
  const _ProfileSkeletonDark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: _DarkTokens.neonViolet,
      ),
    );
  }
}

class _ProfileErrorDark extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorDark({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_outlined, color: Color(0xFFF43F5E), size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger le profil',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _DarkTokens.neonViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dark Theme Toggle Widget
// ─────────────────────────────────────────────────────────────────────────────

class _DarkThemeToggle extends ConsumerWidget {
  const _DarkThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? _DarkTokens.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? _DarkTokens.neonCyan.withValues(alpha: 0.15)
                  : const Color(0xFF5B4FE0).withValues(alpha: 0.1),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: isDark ? _DarkTokens.neonCyan : const Color(0xFF5B4FE0),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thème de l\'application',
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isDark ? 'Mode Sombre (Obsidienne)' : 'Mode Clair (Lavande)',
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).toggle(v),
            activeThumbColor: isDark ? _DarkTokens.neonCyan : const Color(0xFF5B4FE0),
            activeTrackColor: (isDark ? _DarkTokens.neonCyan : const Color(0xFF5B4FE0))
                .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
