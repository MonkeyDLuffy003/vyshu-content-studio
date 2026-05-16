import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/channel_data.dart';
import '../models/content_item.dart';
import '../services/claude_service.dart';
import '../services/storage_service.dart';

class GenerateScreen extends StatefulWidget {
  final ChannelData channel;
  const GenerateScreen({super.key, required this.channel});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedTopic;
  final _customController = TextEditingController();
  bool _loading = false;
  ContentItem? _result;
  int _activeTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customController.dispose();
    super.dispose();
  }

  String get _topic =>
      _customController.text.trim().isNotEmpty
          ? _customController.text.trim()
          : (_selectedTopic ?? '');

  bool get _canGenerate => _topic.isNotEmpty;

  Future<void> _generate() async {
    if (!_canGenerate) return;
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final results = await Future.wait([
        ClaudeService.generate(
            ClaudeService.buildScriptPrompt(widget.channel.id, _topic)),
        ClaudeService.generate(
            ClaudeService.buildPromptsPrompt(widget.channel.id, _topic)),
        ClaudeService.generate(
            ClaudeService.buildCaptionPrompt(widget.channel.id, _topic)),
      ]);

      final item = ContentItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
        channelId: widget.channel.id,
        channelName: widget.channel.name,
        topic: _topic,
        script: results[0],
        imagePrompts: results[1],
        caption: results[2],
        createdAt: DateTime.now(),
      );

      await StorageService.saveItem(item);
      setState(() => _result = item);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyTab() {
    final text = _activeTab == 0
        ? _result!.script
        : _activeTab == 1
            ? _result!.imagePrompts
            : _result!.caption;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard ✓'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF1A1A2E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.channel;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: const Color(0xFF888899),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ch.name,
          style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ch.accent),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ch.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ch.style,
              style: TextStyle(fontSize: 11, color: ch.accent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic section
              const Text(
                'CHOOSE A TOPIC',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF444455),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...ch.topics.map((t) => _TopicChip(
                    label: t,
                    selected: _selectedTopic == t,
                    color: ch.color,
                    accent: ch.accent,
                    onTap: () => setState(() {
                      _selectedTopic = t;
                      _customController.clear();
                    }),
                  )),
              const SizedBox(height: 16),
              const Text(
                '— or type your own —',
                style: TextStyle(fontSize: 11, color: Color(0xFF444455)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customController,
                onChanged: (_) => setState(() => _selectedTopic = null),
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFFE8E8F0)),
                decoration: InputDecoration(
                  hintText: 'e.g. My first AI model failure story...',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: Color(0xFF444455)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: ch.color.withOpacity(0.5)),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canGenerate && !_loading ? _generate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canGenerate ? ch.color : Colors.white.withOpacity(0.05),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ch.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Generating your content...',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        )
                      : const Text('✦  Generate Script + Prompts + Caption',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),

              // Output
              if (_result != null) ...[
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ch.color.withOpacity(0.25)),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: ch.color,
                        labelColor: ch.accent,
                        unselectedLabelColor: const Color(0xFF444455),
                        labelStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                        unselectedLabelStyle:
                            const TextStyle(fontSize: 12),
                        tabs: const [
                          Tab(text: '📝 Script'),
                          Tab(text: '🎨 Prompts'),
                          Tab(text: '✍️ Caption'),
                        ],
                      ),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Text(
                            _activeTab == 0
                                ? _result!.script
                                : _activeTab == 1
                                    ? _result!.imagePrompts
                                    : _result!.caption,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.8,
                              color: Color(0xFFC8C8D8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _copyTab,
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Copy',
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF888899),
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.1)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Saved to 7-day history ✓',
                              style: TextStyle(
                                  fontSize: 11, color: ch.color.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color accent;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Text(
          '${selected ? "✦" : "○"}  $label',
          style: TextStyle(
            fontSize: 13,
            color: selected ? accent : const Color(0xFF888899),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
