import 'dart:convert';

class ContentItem {
  final String id;
  final String channelId;
  final String channelName;
  final String topic;
  final String script;
  final String imagePrompts;
  final String caption;
  final DateTime createdAt;

  ContentItem({
    required this.id,
    required this.channelId,
    required this.channelName,
    required this.topic,
    required this.script,
    required this.imagePrompts,
    required this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'channelId': channelId,
        'channelName': channelName,
        'topic': topic,
        'script': script,
        'imagePrompts': imagePrompts,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
        id: json['id'],
        channelId: json['channelId'],
        channelName: json['channelName'],
        topic: json['topic'],
        script: json['script'],
        imagePrompts: json['imagePrompts'],
        caption: json['caption'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  String toJsonString() => jsonEncode(toJson());
  factory ContentItem.fromJsonString(String s) =>
      ContentItem.fromJson(jsonDecode(s));
}
