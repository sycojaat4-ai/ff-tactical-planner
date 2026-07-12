import 'package:flutter/material.dart';
import 'package:ff_tactical_planner/models/strategy_model.dart';
import 'package:ff_tactical_planner/services/storage_service.dart';
import 'package:ff_tactical_planner/screens/map_screen.dart';
import 'package:ff_tactical_planner/utils/constants.dart';

/// Landing screen: choose a map to start a fresh strategy, or resume a
/// previously saved one. Modern esports dark UI with glass cards.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<StrategyModel> _saved;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _saved = StorageService.getAll());
  }

  void _openMap(GameMap map, {String? strategyId}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => MapScreen(initialMap: map, strategyId: strategyId),
        ))
        .then((_) => _refresh());
  }

  Future<void> _rename(StrategyModel s) async {
    final controller = TextEditingController(text: s.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Strategy', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await StorageService.rename(s.id, newName);
      _refresh();
    }
  }

  Future<void> _delete(StrategyModel s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Strategy?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('"${s.name}" will be permanently removed.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.accentSecondary)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService.delete(s.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentSecondary]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield_moon_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FF Tactical Planner',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text('Esports strategy boards',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Select a Map',
                    style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final map = GameMap.values[index];
                    return _MapCard(map: map, onTap: () => _openMap(map));
                  },
                  childCount: GameMap.values.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text('Saved Strategies',
                    style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            if (_saved.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text('No saved strategies yet.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final s = _saved[index];
                      return _StrategyTile(
                        strategy: s,
                        onOpen: () => _openMap(s.map, strategyId: s.id),
                        onRename: () => _rename(s),
                        onDelete: () => _delete(s),
                      );
                    },
                    childCount: _saved.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final GameMap map;
  final VoidCallback onTap;
  const _MapCard({required this.map, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(map.assetPath, fit: BoxFit.cover, filterQuality: FilterQuality.high),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                map.displayName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyTile extends StatelessWidget {
  final StrategyModel strategy;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _StrategyTile({
    required this.strategy,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(strategy.map.assetPath,
              width: 44, height: 44, fit: BoxFit.cover, filterQuality: FilterQuality.high),
        ),
        title: Text(strategy.name,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${strategy.map.displayName} · ${strategy.markers.length} markers · '
          '${_formatDate(strategy.updatedAt)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surface,
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
          onSelected: (v) {
            if (v == 'rename') onRename();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
                value: 'rename',
                child: Text('Rename', style: TextStyle(color: AppColors.textPrimary))),
            PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.accentSecondary))),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
