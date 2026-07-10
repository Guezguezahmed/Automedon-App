import 'package:flutter/material.dart';
import '../theme.dart';

/// Modèle temporaire en attendant le vrai modèle / provider Client B2B.
/// À remplacer par un vrai `B2BClient` (models/b2b_client.dart) une fois
/// l'endpoint backend correspondant disponible.
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

  // MOCK — à remplacer par ref.watch(b2bClientsProvider) une fois branché.
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

  void _showDeleteConfirm(BuildContext context, B2BClientMock client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le client'),
        content: Text('Voulez-vous vraiment supprimer "${client.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: appel API / provider de suppression
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final clients = _filteredClients;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clients B2B',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text(
              '${_clients.length} client${_clients.length > 1 ? 's' : ''} enregistré${_clients.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: navigation vers l'écran de création de client B2B
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Client'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un client',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search,
                  size: 20, color: AppTheme.textSecondary),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (clients.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'Aucun client trouvé',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...clients.map(
                  (client) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ClientCard(
                  client: client,
                  accentColor: primaryColor,
                  onEdit: () {
                    // TODO: navigation vers l'écran d'édition
                  },
                  onDelete: () => _showDeleteConfirm(context, client),
                  onTap: () {
                    // TODO: navigation vers le détail client (fiche chauffeurs, etc.)
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final B2BClientMock client;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ClientCard({
    required this.client,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                'CLIENT #${client.id}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Bloc contact
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          size: 16, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact : ${client.contactName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          client.phone,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Ligne chauffeurs + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 15, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        '${client.driversCount} chauffeur${client.driversCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppTheme.textSecondary),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        splashRadius: 18,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}