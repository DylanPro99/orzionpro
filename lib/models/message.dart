import 'dart:typed_data';
import 'package:uuid/uuid.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

class MessageReaction {
  final String emoji;
  final DateTime timestamp;

  MessageReaction({
    required this.emoji,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      MessageReaction(
        emoji: json['emoji'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class MessageEdit {
  final String content;
  final DateTime timestamp;

  MessageEdit({
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageEdit.fromJson(Map<String, dynamic> json) => MessageEdit(
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? imageUrls;
  final List<Uint8List>? imageBytes;
  final List<String>? fileUrls;
  final bool isStreaming;
  final bool isImageGeneration;

  final bool isPinned;
  final bool isFavorite;
  final List<MessageReaction> reactions;
  final List<String> tags;
  final List<MessageEdit> editHistory;
  final String? audioPath;
  final String? translatedContent;
  final String? ocrText;
  final Map<String, dynamic>? metadata;

  Message({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.imageUrls,
    this.imageBytes,
    this.fileUrls,
    this.isStreaming = false,
    this.isImageGeneration = false,
    this.isPinned = false,
    this.isFavorite = false,
    List<MessageReaction>? reactions,
    List<String>? tags,
    List<MessageEdit>? editHistory,
    this.audioPath,
    this.translatedContent,
    this.ocrText,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        reactions = reactions ?? [],
        tags = tags ?? [],
        editHistory = editHistory ?? [];

  Message copyWith({
    String? content,
    bool? isStreaming,
    List<String>? imageUrls,
    List<Uint8List>? imageBytes,
    List<String>? fileUrls,
    bool? isPinned,
    bool? isFavorite,
    List<MessageReaction>? reactions,
    List<String>? tags,
    List<MessageEdit>? editHistory,
    String? audioPath,
    String? translatedContent,
    String? ocrText,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      imageUrls: imageUrls ?? this.imageUrls,
      imageBytes: imageBytes ?? this.imageBytes,
      fileUrls: fileUrls ?? this.fileUrls,
      isStreaming: isStreaming ?? this.isStreaming,
      isImageGeneration: isImageGeneration,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      reactions: reactions ?? this.reactions,
      tags: tags ?? this.tags,
      editHistory: editHistory ?? this.editHistory,
      audioPath: audioPath ?? this.audioPath,
      translatedContent: translatedContent ?? this.translatedContent,
      ocrText: ocrText ?? this.ocrText,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'imageUrls': imageUrls,
      'fileUrls': fileUrls,
      'isStreaming': isStreaming,
      'isImageGeneration': isImageGeneration,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'tags': tags,
      'editHistory': editHistory.map((e) => e.toJson()).toList(),
      'audioPath': audioPath,
      'translatedContent': translatedContent,
      'ocrText': ocrText,
      'metadata': metadata,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      fileUrls:
          json['fileUrls'] != null ? List<String>.from(json['fileUrls']) : null,
      isStreaming: json['isStreaming'] ?? false,
      isImageGeneration: json['isImageGeneration'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((r) => MessageReaction.fromJson(r))
              .toList()
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      editHistory: json['editHistory'] != null
          ? (json['editHistory'] as List)
              .map((e) => MessageEdit.fromJson(e))
              .toList()
          : null,
      audioPath: json['audioPath'],
      translatedContent: json['translatedContent'],
      ocrText: json['ocrText'],
      metadata: json['metadata'],
    );
  }
}
