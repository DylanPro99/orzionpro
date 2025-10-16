import 'package:uuid/uuid.dart';
import 'message.dart';
import 'chat_model.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrzionModel model;

  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final String? folder;
  final List<String> tags;
  final String? description;
  final int color;
  final String? customAvatar;
  final Map<String, dynamic>? metadata;

  Conversation({
    String? id,
    required this.title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.model,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.folder,
    List<String>? tags,
    this.description,
    this.color = 0xFF6C63FF,
    this.customAvatar,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [];

  Conversation copyWith({
    String? title,
    List<Message>? messages,
    DateTime? updatedAt,
    OrzionModel? model,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    String? folder,
    List<String>? tags,
    String? description,
    int? color,
    String? customAvatar,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      model: model ?? this.model,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      color: color ?? this.color,
      customAvatar: customAvatar ?? this.customAvatar,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'model': model.name,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'folder': folder,
      'tags': tags,
      'description': description,
      'color': color,
      'customAvatar': customAvatar,
      'metadata': metadata,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      model: OrzionModel.values.firstWhere((e) => e.name == json['model']),
      isPinned: json['isPinned'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      isArchived: json['isArchived'] ?? false,
      folder: json['folder'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      description: json['description'],
      color: json['color'] ?? 0xFF6C63FF,
      customAvatar: json['customAvatar'],
      metadata: json['metadata'],
    );
  }
}
