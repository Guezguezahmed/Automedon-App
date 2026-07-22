import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class B2BClientMock {
  final String id;
  final String name;
  final String contactName;
  final String phone;
  final int driversCount;

  const B2BClientMock({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.driversCount,
  });
}

class AgencesScreen extends StatefulWidget {
  const AgencesScreen({super.key});

  @override
  State<AgencesScreen> createState() => _AgencesScreenState();
}

class _AgencesScreenState extends State<AgencesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<B2BClientMock> _clients = const [
    B2BClientMock(
      id: '12025887',
      name: 'STE NABEUL',
      contactName: 'Liwa',
      phone: '29 662 308',
      driversCount: 1,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<B2BClientMock> get _filteredClients {
    if (_query.trim().isEmpty) return _clients;
    final q = _query.toLowerCase();
    return _clients
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.contactName.toLowerCase().contains(q))
        .toList();
  }

  void _showDeleteConfirm(BuildContext context, B2BClientMock client, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.surface0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
        ),
        title: Text('Supprimer le client', style: AppTextStyles.displayMd(color: isDark ? Colors.white : AppTheme.ink900)),
        content: Text('Voulez-vous vraiment supprimer "${client.name}" ?', style: AppTextStyles.bodyMd(color: isDark ? Colors.white70 : AppTheme.ink600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: AppTextStyles.bodyLg(color: isDark ? Colors.white60 : AppTheme.ink600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text('Supprimer', style: AppTextStyles.bodyLg(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clients = _filteredClients;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        appBar: AppBar(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Clients B2B', style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900)),
              Text(
                '${_clients.length} client${_clients.length > 1 ? 's' : ''} enregistré${_clients.length > 1 ? 's' : ''}',
                style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.sp4),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Client'),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppTheme.sp4, AppTheme.sp4, AppTheme.sp4, 120),
          physics: const BouncingScrollPhysics(),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
              decoration: InputDecoration(
                hintText: 'Rechercher un client',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.ink400),
                prefixIcon: Icon(Icons.search, size: 20, color: isDark ? AppTheme.neonViolet : AppTheme.ink400),
                fillColor: isDark ? AppTheme.darkSurface : AppTheme.surface0,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: isDark ? AppTheme.neonViolet : AppTheme.primary600, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.sp4),

            if (clients.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.people_outline,
                    title: 'Aucun client trouvé',
                    description: 'Aucun client ne correspond à votre recherche.',
                  ),
                ),
              )
            else
              ...clients.map(
                (client) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sp3),
                  child: _ClientCard(
                    client: client,
                    isDark: isDark,
                    onEdit: () {},
                    onDelete: () => _showDeleteConfirm(context, client, isDark),
                    onTap: () {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final B2BClientMock client;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.sp4),
      hasGlow: isDark,
      glowColor: isDark ? AppTheme.neonCyan : null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client.name,
            style: AppTextStyles.displayMd(color: isDark ? Colors.white : AppTheme.ink900),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              'CLIENT #${client.id}',
              style: AppTextStyles.dataSm(color: isDark ? Colors.white70 : AppTheme.ink600),
            ),
          ),
          const SizedBox(height: AppTheme.sp3),
          Container(
            padding: const EdgeInsets.all(AppTheme.sp3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1642) : AppTheme.surfaceApp,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
            ),
            child: Row(
              children: [
                AppIconCircle(
                  icon: Icons.person_outline,
                  color: isDark ? AppTheme.neonViolet : AppTheme.primary600,
                  backgroundColor: isDark ? const Color(0xFF2A205E) : Colors.white,
                  size: 38,
                  iconSize: 18,
                  hasGlow: isDark,
                ),
                const SizedBox(width: AppTheme.sp3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact : ${client.contactName}',
                      style: AppTextStyles.bodyLg(color: isDark ? Colors.white : AppTheme.ink900),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      client.phone,
                      style: AppTextStyles.dataSm(color: isDark ? Colors.white70 : AppTheme.ink600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: isDark ? AppTheme.neonCyan : AppTheme.primary600),
                  const SizedBox(width: 6),
                  Text(
                    '${client.driversCount} chauffeur${client.driversCount > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMd(color: isDark ? Colors.white70 : AppTheme.ink600),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, size: 18, color: isDark ? Colors.white70 : AppTheme.ink600),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}