import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  // Replace with your Claude API key
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';

  static Future<String> generate(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 1000,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] ?? '';
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  static String buildScriptPrompt(String channelId, String topic) {
    final isStory =
        channelId == 'insta1' || channelId == 'youtube';
    if (isStory) {
      return '''You are a creative director for an anime/animation-style YouTube & Instagram channel. 
The creator is "Vyshu" — a young person sharing their real AI learning journey in a cinematic story format.

Write a compelling VIDEO SCRIPT for topic: "$topic"
Duration: 1–3 minutes

Format:
HOOK (0–10s): [Dramatic opening line spoken by Vyshu]
SCENE 1 (10–40s): [Story beat with emotion]
SCENE 2 (40–80s): [Key insight or struggle]
SCENE 3 (80–120s): [Turning point]
OUTRO (last 10s): [Call to action]

Make it feel personal, emotional, and cinematic. Use "I" as Vyshu speaking.''';
    } else {
      return '''You are a social media strategist for "Vyshu AI" — an AI tech influencer on Instagram.

Write a punchy VIDEO SCRIPT for topic: "$topic"
Duration: 30–60 seconds

Format:
HOOK (0–5s): [Scroll-stopping opener]
POINT 1 (5–20s): [Key insight]
POINT 2 (20–35s): [Surprising fact or tip]
CTA (35–45s): [Follow + save]

Keep it fast, confident, trendy. Speak directly to the viewer.''';
    }
  }

  static String buildPromptsPrompt(String channelId, String topic) {
    final isStory =
        channelId == 'insta1' || channelId == 'youtube';
    if (isStory) {
      return '''Generate 4 detailed AI image generation prompts for an ANIMATION/ANIME style video about: "$topic"
These are scene visuals for a YouTube/Instagram story video by a young Indian AI creator named Vyshu.

For each scene write:
SCENE [n]: [2-sentence visual prompt optimized for Pollinations.AI or Hugging Face]
Style: anime cinematic, warm lighting, detailed backgrounds, emotional expression

Make them vivid, specific, and visually storytelling.''';
    } else {
      return '''Generate 3 AI image prompts for an Instagram tech influencer post about: "$topic"
The influencer is "Vyshu AI" — a stylish, modern AI personality.

For each:
VISUAL [n]: [Detailed prompt for a bold, eye-catching tech aesthetic image]
Style: futuristic, sleek, dark mode vibes, neon accents, social-media-ready''';
    }
  }

  static String buildCaptionPrompt(String channelId, String topic) {
    final isStory =
        channelId == 'insta1' || channelId == 'youtube';
    if (isStory) {
      return '''Write an Instagram/YouTube caption for a video about: "$topic"
Channel style: cinematic AI life journey, animation aesthetic, personal & emotional.

Include:
- Hook first line (no emoji to start)
- 3–4 lines of story
- 5–8 relevant hashtags
- Call to action

Keep it authentic, not corporate.''';
    } else {
      return '''Write an Instagram caption for "Vyshu AI" tech influencer post about: "$topic"

Include:
- Bold punchy first line
- 2–3 sharp insights
- 5–7 trending AI hashtags
- Engaging CTA

Tone: confident, trendy, smart. Max 150 words.''';
    }
  }
}
