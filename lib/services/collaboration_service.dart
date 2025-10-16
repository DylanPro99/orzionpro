import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../models/conversation.dart';

class Template {
  final String id;
  final String name;
  final String description;
  final String content;
  final List<String> tags;
  final DateTime createdAt;

  Template({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    required this.tags,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'content': content,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        content: json['content'],
        tags: List<String>.from(json['tags']),
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class CollaborationService {
  final List<Template> _templates = [
    Template(
      id: '1',
      name: 'Resumen de Texto',
      description: 'Resume el siguiente texto de manera concisa',
      content: 'Por favor, resume el siguiente texto manteniendo los puntos más importantes:\n\n[Tu texto aquí]',
      tags: ['resumen', 'productividad'],
    ),
    Template(
      id: '2',
      name: 'Corrección de Gramática',
      description: 'Corrige gramática y ortografía',
      content: 'Corrige la gramática y ortografía del siguiente texto:\n\n[Tu texto aquí]',
      tags: ['gramática', 'escritura'],
    ),
    Template(
      id: '3',
      name: 'Traducción',
      description: 'Traduce texto a otro idioma',
      content: 'Traduce el siguiente texto al [idioma]:\n\n[Tu texto aquí]',
      tags: ['traducción', 'idiomas'],
    ),
    Template(
      id: '4',
      name: 'Ideas Creativas',
      description: 'Genera ideas creativas para un proyecto',
      content: 'Dame 10 ideas creativas e innovadoras para:\n\n[Describe tu proyecto]',
      tags: ['creatividad', 'brainstorming'],
    ),
    Template(
      id: '5',
      name: 'Análisis de Código',
      description: 'Analiza y mejora código',
      content: 'Analiza el siguiente código y sugiere mejoras:\n\n```\n[Tu código aquí]\n```',
      tags: ['código', 'programación'],
    ),
  ];

  List<Template> get templates => _templates;

  Future<String> shareConversation(Conversation conversation) async {
    final jsonData = jsonEncode(conversation.toJson());
    final encodedData = base64Encode(utf8.encode(jsonData));
    
    final shareUrl = 'orzion://share?data=$encodedData';
    
    await Share.share(
      shareUrl,
      subject: 'Compartir conversación: ${conversation.title}',
    );
    
    return shareUrl;
  }

  String generateQRCode(String data) {
    return data;
  }

  Future<Conversation?> importConversation(String encodedData) async {
    try {
      final jsonData = utf8.decode(base64Decode(encodedData));
      final Map<String, dynamic> data = jsonDecode(jsonData);
      return Conversation.fromJson(data);
    } catch (e) {
      print('Error importing conversation: $e');
      return null;
    }
  }

  Template? getTemplateById(String id) {
    return _templates.firstWhere((t) => t.id == id);
  }

  List<Template> searchTemplates(String query) {
    final lowerQuery = query.toLowerCase();
    return _templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
