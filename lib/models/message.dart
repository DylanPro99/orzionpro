import 'dart:typed_data';
import 'package:uuid/uuid.dart';

enum MessageRole {
  user,
  assistant,
  system,
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
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    bool? isStreaming,
    List<String>? imageUrls,
    List<Uint8List>? imageBytes,
    List<String>? fileUrls,
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
    );
  }
}
