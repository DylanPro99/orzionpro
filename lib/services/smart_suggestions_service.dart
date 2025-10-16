import 'package:flutter/material.dart';
import '../models/message.dart';

class SmartSuggestion {
  final String text;
  final String description;
  final IconData? icon;
  final SuggestionType type;

  const SmartSuggestion({
    required this.text,
    required this.description,
    this.icon,
    required this.type,
  });
}

enum SuggestionType {
  quickReply,
  followUp,
  command,
  template,
}

class SmartSuggestionsService {
  static List<SmartSuggestion> getQuickReplies(List<Message> recentMessages) {
    if (recentMessages.isEmpty) return [];
    
    final lastMessage = recentMessages.last;
    if (lastMessage.role != MessageRole.assistant) return [];
    
    final content = lastMessage.content.toLowerCase();
    
    final suggestions = <SmartSuggestion>[];
    
    if (content.contains('?')) {
      suggestions.addAll([
        const SmartSuggestion(
          text: 'Sí, por favor explica más',
          description: 'Solicitar más detalles',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'No, dame otra opción',
          description: 'Buscar alternativas',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'Muéstrame un ejemplo',
          description: 'Ver ejemplos',
          type: SuggestionType.quickReply,
        ),
      ]);
    }
    
    if (content.contains('código') || content.contains('code') || content.contains('```')) {
      suggestions.addAll([
        const SmartSuggestion(
          text: 'Explícame cómo funciona',
          description: 'Entender el código',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'Optimiza este código',
          description: 'Mejorar rendimiento',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'Añade comentarios',
          description: 'Documentar código',
          type: SuggestionType.quickReply,
        ),
      ]);
    }
    
    if (content.contains('imagen') || content.contains('image') || lastMessage.isImageGeneration == true) {
      suggestions.addAll([
        const SmartSuggestion(
          text: 'Genera otra variación',
          description: 'Nueva versión',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'Cambia el estilo',
          description: 'Modificar estilo',
          type: SuggestionType.quickReply,
        ),
        const SmartSuggestion(
          text: 'Hazla más realista',
          description: 'Aumentar realismo',
          type: SuggestionType.quickReply,
        ),
      ]);
    }
    
    suggestions.addAll([
      const SmartSuggestion(
        text: 'Continúa',
        description: 'Seguir con el tema',
        type: SuggestionType.quickReply,
      ),
      const SmartSuggestion(
        text: 'Explica de forma simple',
        description: 'Simplificar explicación',
        type: SuggestionType.quickReply,
      ),
    ]);
    
    return suggestions.take(5).toList();
  }

  static List<SmartSuggestion> getFollowUpQuestions(List<Message> conversation) {
    final suggestions = <SmartSuggestion>[];
    
    if (conversation.isEmpty) {
      return [
        const SmartSuggestion(
          text: '¿Qué puedes hacer?',
          description: 'Conocer capacidades',
          type: SuggestionType.followUp,
        ),
        const SmartSuggestion(
          text: 'Ayúdame con código',
          description: 'Asistencia programación',
          type: SuggestionType.followUp,
        ),
        const SmartSuggestion(
          text: 'Genera una imagen',
          description: 'Crear imagen',
          type: SuggestionType.followUp,
        ),
      ];
    }
    
    final topics = _extractTopics(conversation);
    
    for (final topic in topics) {
      suggestions.add(SmartSuggestion(
        text: '¿Puedes ampliar sobre $topic?',
        description: 'Profundizar en tema',
        type: SuggestionType.followUp,
      ));
    }
    
    return suggestions.take(3).toList();
  }

  static List<String> _extractTopics(List<Message> conversation) {
    final topics = <String>[];
    final commonWords = {'el', 'la', 'los', 'las', 'un', 'una', 'de', 'en', 'a', 'y', 'o', 'que', 'por', 'para', 'con'};
    
    for (final message in conversation.reversed.take(3)) {
      final words = message.content.toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(' ')
          .where((w) => w.length > 4 && !commonWords.contains(w))
          .take(2);
      
      topics.addAll(words);
      if (topics.length >= 3) break;
    }
    
    return topics.take(3).toList();
  }

  static List<SmartSuggestion> getStarterTemplates() {
    return const [
      SmartSuggestion(
        text: 'Explica un concepto complejo',
        description: 'Para aprender algo nuevo',
        type: SuggestionType.template,
      ),
      SmartSuggestion(
        text: 'Ayúdame a escribir código',
        description: 'Asistencia de programación',
        type: SuggestionType.template,
      ),
      SmartSuggestion(
        text: 'Genera una imagen de',
        description: 'Crear imagen personalizada',
        type: SuggestionType.template,
      ),
      SmartSuggestion(
        text: 'Resume este texto',
        description: 'Resumir contenido',
        type: SuggestionType.template,
      ),
      SmartSuggestion(
        text: 'Traduce al inglés',
        description: 'Traducción de idiomas',
        type: SuggestionType.template,
      ),
      SmartSuggestion(
        text: 'Corrige mi gramática',
        description: 'Mejorar escritura',
        type: SuggestionType.template,
      ),
    ];
  }

  static String generateSmartTitle(List<Message> messages) {
    if (messages.isEmpty) return 'Nueva conversación';
    
    final userMessages = messages
        .where((m) => m.role == MessageRole.user)
        .take(3)
        .toList();
    
    if (userMessages.isEmpty) return 'Nueva conversación';
    
    final firstMessage = userMessages.first.content;
    
    final cleanText = firstMessage
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    
    if (cleanText.length <= 50) {
      return _capitalizeFirst(cleanText);
    }
    
    final words = cleanText.split(' ');
    final importantWords = words.where((w) => w.length > 3).take(6).join(' ');
    
    return _capitalizeFirst(importantWords);
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static int estimateContextTokens(List<Message> messages) {
    int tokens = 0;
    
    for (final message in messages) {
      tokens += (message.content.length / 4).ceil();
      
      if (message.imageBytes != null && message.imageBytes!.isNotEmpty) {
        tokens += 85 * message.imageBytes!.length;
      }
      
      if (message.fileUrls != null && message.fileUrls!.isNotEmpty) {
        tokens += 1000 * message.fileUrls!.length;
      }
    }
    
    return tokens;
  }

  static String getContextSizeDescription(int tokens) {
    if (tokens < 1000) return 'Contexto pequeño (< 1K tokens)';
    if (tokens < 4000) return 'Contexto medio (${(tokens/1000).toStringAsFixed(1)}K tokens)';
    if (tokens < 16000) return 'Contexto grande (${(tokens/1000).toStringAsFixed(1)}K tokens)';
    return 'Contexto muy grande (${(tokens/1000).toStringAsFixed(1)}K tokens)';
  }
}
