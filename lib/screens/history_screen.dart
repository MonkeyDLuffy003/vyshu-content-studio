import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/content_item.dart';
import '../models/channel_data.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ContentItem> _items = [];
  bool _loading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await StorageService.loadItems();
    final stats = await StorageService.getStorageStats();
    setState(() {
      _items = items;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    await StorageService.deleteItem(id);
    await _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F1A),
        title: const Text('Clear all history?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'This will delete all 7-day stored content. Cannot be undone.',
            style: TextStyle(color: Color(0xFF888899))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888899))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.clearAll();
      await _load();
    }
  }

  ChannelData _channelFor(String id) =>
      channels.firstWhere((c) => c.id == id, orElse: () => channels[0]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Day History',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Auto-cleaned after 7 days',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF555566)),
                      ),
                    ],
                  ),
                  if (_items.isNotEmpty)
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear All',
                          style: TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),

            // Stats bar
            if (_stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _stats.entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: e.value > 0
                            ? const Color(0xFF6366F1).withOpacity(0.15)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: e.value > 0
                              ? const Color(0xFF6366F1).withOpacity(0.4)
                              : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${e.value}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: e.value > 0
                                  ? const Color(0xFFA5B4FC)
                                  : const Color(0xFF444455),
                            ),
                          ),
                          Text(
                            e.key,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF555566)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF6366F1)))
                  : _items.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: const Color(0xFF6366F1),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _items.length,
                            itemBuilder: (ctx, i) {
                              final item = _items[i];
                              final ch = _channelFor(item.channelId);
                              return _HistoryCard(
                                item: item,
                                channel: ch,
                                onDelete: () => _deleteItem(item.id),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final ContentItem item;
  final ChannelData channel;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.channel,
    required this.onDelete,
  });

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;
  int _activeTab = 0;

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied ✓'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1A1A2E),
      ),
    );
  }

  String get _daysLeft {
    final diff = 7 -
        DateTime.now().difference(widget.item.createdAt).inDays;
    return diff == 1 ? '1 day left' : '$diff days left';
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.channel;
    final dateStr =
        DateFormat('MMM d, h:mm a').format(widget.item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ch.color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(ch.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.topic,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE8E8F0)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF555566)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ch.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _daysLeft,
                                style: TextStyle(
                                    fontSize: 10, color: ch.accent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Icon(Icons.delete_outline,
                            size: 18, color: Colors.red.withOpacity(0.5)),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF444455),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.05),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TabBtn(
                          label: '📝 Script',
                          active: _activeTab == 0,
                          color: ch.color,
                          onTap: () =>
                              setState(() => _activeTab = 0)),
                      const SizedBox(width: 8),
                      _TabBtn(
                          label: '🎨 Prompts',
                          active: _activeTab == 1,
                          color: ch.color,
                          onTap: () =>
                              setState(() => _activeTab = 1)),
                      const SizedBox(width: 8),
                      _TabBtn(
                          label: '✍️ Caption',
                          active: _activeTab == 2,
                          color: ch.color,
                          onTap: () =>
                              setState(() => _activeTab = 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        _activeTab == 0
                            ? widget.item.script
                            : _activeTab == 1
                                ? widget.item.imagePrompts
                                : widget.item.caption,
                        style: const TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: Color(0xFFAAAAAA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _copy(_activeTab == 0
                        ? widget.item.script
                        : _activeTab == 1
                            ? widget.item.imagePrompts
                            : widget.item.caption),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, size: 13, color: Color(0xFF888899)),
                          SizedBox(width: 6),
                          Text('Copy',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF888899))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color.withOpacity(0.5) : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? Colors.white : const Color(0xFF555566),
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No content yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888899)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate your first video content\nfrom the Create tab',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF444455)),
          ),
        ],
      ),
    );
  }
}
