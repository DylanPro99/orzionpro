import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MessageDraft {
  final String conversationId;
  final String content;
  final DateTime timestamp;
  final List<String>? attachments;

  MessageDraft({
    required this.conversationId,
    required this.content,
    required this.timestamp,
    this.attachments,
  });

  Map<String, dynamic> toJson() => {
        'conversationId': conversationId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'attachments': attachments,
      };

  factory MessageDraft.fromJson(Map<String, dynamic> json) => MessageDraft(
        conversationId: json['conversationId'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        attachments: json['attachments'] != null
            ? List<String>.from(json['attachments'])
            : null,
      );
}

class DraftService {
  static const String _draftKey = 'message_drafts';

  Future<void> saveDraft(MessageDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();
    
    drafts.removeWhere((d) => d.conversationId == draft.conversationId);
    drafts.add(draft);
    
    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftKey, draftsJson);
  }

  Future<MessageDraft?> getDraft(String conversationId) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d.conversationId == conversationId);
    } catch (e) {
      return null;
    }
  }

  Future<List<MessageDraft>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(_draftKey) ?? [];
    
    return draftsJson
        .map((json) => MessageDraft.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> deleteDraft(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();
    
    drafts.removeWhere((d) => d.conversationId == conversationId);
    
    final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftKey, draftsJson);
  }

  Future<void> clearOldDrafts({Duration maxAge = const Duration(days: 7)}) async {
    final drafts = await getAllDrafts();
    final now = DateTime.now();
    
    final validDrafts = drafts.where((d) {
      return now.difference(d.timestamp) < maxAge;
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = validDrafts.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_draftKey, draftsJson);
  }
}
