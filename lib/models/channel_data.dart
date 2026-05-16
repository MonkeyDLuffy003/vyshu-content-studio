import 'package:flutter/material.dart';

class ChannelData {
  final String id;
  final String name;
  final String handle;
  final String icon;
  final String style;
  final Color color;
  final Color accent;
  final String duration;
  final String desc;
  final List<String> topics;

  const ChannelData({
    required this.id,
    required this.name,
    required this.handle,
    required this.icon,
    required this.style,
    required this.color,
    required this.accent,
    required this.duration,
    required this.desc,
    required this.topics,
  });
}

final List<ChannelData> channels = [
  ChannelData(
    id: 'insta1',
    name: 'Insta · Life Journey',
    handle: '@vyshu_ailife',
    icon: '📱',
    style: 'Animation Story',
    color: const Color(0xFFF97316),
    accent: const Color(0xFFFDBA74),
    duration: '1–3 mins',
    desc: 'Your AI journey, animated cinematic style',
    topics: [
      'The day I discovered AI changed everything',
      'My first AI project that failed (and what I learned)',
      'How I went from zero to building AI apps',
      'Late night coding sessions & breakthroughs',
      'The tools that made me a better AI creator',
      'When AI gave me my first viral moment',
    ],
  ),
  ChannelData(
    id: 'youtube',
    name: 'YouTube · AI Journey',
    handle: 'Vyshu AI',
    icon: '▶',
    style: 'Story Vlog',
    color: const Color(0xFFEF4444),
    accent: const Color(0xFFFCA5A5),
    duration: '1–3 mins',
    desc: 'Deep storytelling episodes of your AI path',
    topics: [
      'My full AI learning roadmap episode 1',
      'Building my first AI tool from scratch',
      'Struggles nobody talks about in AI',
      'How I built a free AI content pipeline',
      'A week in my life as an AI creator',
      'What I wish I knew before starting AI',
    ],
  ),
  ChannelData(
    id: 'insta2',
    name: 'Insta · Vyshu AI',
    handle: '@vyshu_ai',
    icon: '🤖',
    style: 'Tech Influencer',
    color: const Color(0xFF6366F1),
    accent: const Color(0xFFA5B4FC),
    duration: '30–60 secs',
    desc: 'AI tools, trends & tech takes as influencer',
    topics: [
      'Top 3 free AI image tools this week',
      'Grok vs Gemini – which is better for creators?',
      'How to generate videos for free in 2026',
      'AI tools that will blow your mind',
      'This AI trick saves me 3 hours a day',
      'Best free AI APIs every creator must know',
    ],
  ),
];

const Map<String, List<String>> freeTools = {
  '🖼 Image Generation': [
    'Pollinations.AI — Free, no login needed',
    'Hugging Face FLUX — Free tier',
    'Google Gemini AI Studio — Free tier',
  ],
  '🎬 Video Generation': [
    'PixVerse — 60 credits/day (free)',
    'Kling AI — 66 credits/day (free)',
    'Hailuo AI — 3 videos/day (free)',
  ],
  '✂️ Editing': [
    'CapCut — Free, no watermark',
    'DaVinci Resolve — Free desktop app',
  ],
};
