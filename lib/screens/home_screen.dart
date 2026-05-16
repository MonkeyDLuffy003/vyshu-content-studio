import 'package:flutter/material.dart';
import '../models/channel_data.dart';
import 'generate_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: _navIndex == 0 ? const _ChannelHome() : const HistoryScreen(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1A1A2E), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          backgroundColor: const Color(0xFF0A0A0F),
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: const Color(0xFF444455),
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '7-Day History',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelHome extends StatelessWidget {
  const _ChannelHome();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '✦ Vyshu Studio',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.4)),
                        ),
                        child: const Text(
                          '3 vids/day · free',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA5B4FC),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select a channel to generate content',
                    style: TextStyle(fontSize: 13, color: Color(0xFF666680)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'YOUR CHANNELS',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF444455),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final ch = channels[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChannelCard(channel: ch),
                  );
                },
                childCount: channels.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _FreeToolsCard(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final ChannelData channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenerateScreen(channel: channel),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              channel.color.withOpacity(0.12),
              channel.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: channel.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(channel.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: channel.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    channel.desc,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888899)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: channel.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: channel.color.withOpacity(0.4)),
                  ),
                  child: Text(
                    channel.duration,
                    style: TextStyle(
                        fontSize: 11,
                        color: channel.accent,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: channel.color.withOpacity(0.6)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeToolsCard extends StatefulWidget {
  @override
  State<_FreeToolsCard> createState() => _FreeToolsCardState();
}

class _FreeToolsCardState extends State<_FreeToolsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🛠  Free Tools Reference',
                    style: TextStyle(fontSize: 13, color: Color(0xFF888899)),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF555566),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: freeTools.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        entry.key,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF444455),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((tool) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '✦  $tool',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF777788)),
                            ),
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
