import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/chat_model.dart';
import '../services/openrouter_service.dart';

class ChatProvider with ChangeNotifier {
  final OpenRouterService _openRouterService = OpenRouterService();
  
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList('conversations') ?? [];
    _conversations = conversationsJson
        .map((json) => Conversation.fromJson(jsonDecode(json)))
        .toList();
    
    if (_conversations.isNotEmpty) {
      _currentConversation = _conversations.first;
    }
    
    notifyListeners();
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = _conversations
        .map((conv) => jsonEncode(conv.toJson()))
        .toList();
    await prefs.setStringList('conversations', conversationsJson);
  }

  void createNewConversation(ChatModel model) {
    _currentConversation = Conversation(
      title: 'Nueva conversación',
      model: model.type,
    );
    _conversations.insert(0, _currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void selectConversation(Conversation conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  void deleteConversation(String conversationId) {
    _conversations.removeWhere((conv) => conv.id == conversationId);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = _conversations.isNotEmpty ? _conversations.first : null;
    }
    _saveConversations();
    notifyListeners();
  }

  Future<void> sendMessage(
    String content,
    ChatModel model, {
    List<String>? imagePaths,
    List<Uint8List>? imageBytes,
    List<String>? filePaths,
  }) async {
    if (_currentConversation == null) {
      createNewConversation(model);
    }

    final userMessage = Message(
      content: content,
      role: MessageRole.user,
      imageUrls: imagePaths,
      imageBytes: imageBytes,
      fileUrls: filePaths,
    );

    _currentConversation = _currentConversation!.copyWith(
      messages: [..._currentConversation!.messages, userMessage],
      updatedAt: DateTime.now(),
    );

    if (_currentConversation!.messages.length == 1) {
      final title = content.length > 50 ? '${content.substring(0, 50)}...' : content;
      _currentConversation = _currentConversation!.copyWith(title: title);
    }

    _updateConversation(_currentConversation!);
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shouldGenerateImage = _detectImageRequest(content);
      
      if (shouldGenerateImage) {
        final imageMessage = Message(
          content: 'Generando imagen...',
          role: MessageRole.assistant,
          isStreaming: true,
          isImageGeneration: true,
        );
        
        _currentConversation = _currentConversation!.copyWith(
          messages: [..._currentConversation!.messages, imageMessage],
        );
        _updateConversation(_currentConversation!);
        notifyListeners();

        final imageUrl = await _openRouterService.generateImage(content);
        
        final updatedMessages = _currentConversation!.messages.map((msg) {
          if (msg.id == imageMessage.id) {
            return msg.copyWith(
              content: 'Aquí está tu imagen:',
              imageUrls: [imageUrl],
              isStreaming: false,
            );
          }
          return msg;
        }).toList();

        _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
        _updateConversation(_currentConversation!);
      } else {
        final assistantMessage = Message(
          content: '',
          role: MessageRole.assistant,
          isStreaming: true,
        );

        _currentConversation = _currentConversation!.copyWith(
          messages: [..._currentConversation!.messages, assistantMessage],
        );
        _updateConversation(_currentConversation!);
        notifyListeners();

        final responseStream = _openRouterService.sendMessageStream(
          messages: _currentConversation!.messages,
          model: model,
          imageBytes: imageBytes,
        );

        await for (final chunk in responseStream) {
          final updatedMessages = _currentConversation!.messages.map((msg) {
            if (msg.id == assistantMessage.id) {
              return msg.copyWith(content: msg.content + chunk);
            }
            return msg;
          }).toList();

          _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
          _updateConversation(_currentConversation!);
          notifyListeners();
        }

        final finalMessages = _currentConversation!.messages.map((msg) {
          if (msg.id == assistantMessage.id) {
            return msg.copyWith(isStreaming: false);
          }
          return msg;
        }).toList();

        _currentConversation = _currentConversation!.copyWith(messages: finalMessages);
        _updateConversation(_currentConversation!);
      }
    } catch (e) {
      _error = e.toString();
      final errorMessage = Message(
        content: 'Error: $e',
        role: MessageRole.assistant,
      );
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, errorMessage],
      );
      _updateConversation(_currentConversation!);
    } finally {
      _isLoading = false;
      notifyListeners();
      _saveConversations();
    }
  }

  bool _detectImageRequest(String text) {
    final imageKeywords = [
      'imagen',
      'foto',
      'picture',
      'image',
      'visual',
      'dibuja',
      'dibujo',
      'genera una imagen',
      'crea una imagen',
      'genérame',
      'crea un dibujo',
      'draw',
      'illustration',
      'ilustración',
    ];

    final lowerText = text.toLowerCase();
    return imageKeywords.any((keyword) => lowerText.contains(keyword));
  }

  void _updateConversation(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void editMessage(String messageId, String newContent) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        final editHistory = [
          ...msg.editHistory,
          MessageEdit(content: msg.content),
        ];
        return msg.copyWith(content: newContent, editHistory: editHistory);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages
        .where((msg) => msg.id != messageId)
        .toList();

    _currentConversation = _currentConversation!.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    );
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void togglePinMessage(String messageId) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isPinned: !msg.isPinned);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void toggleFavoriteMessage(String messageId) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(isFavorite: !msg.isFavorite);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void addReaction(String messageId, String emoji) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        final reactions = [...msg.reactions, MessageReaction(emoji: emoji)];
        return msg.copyWith(reactions: reactions);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void removeReaction(String messageId, String emoji) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        final reactions = msg.reactions.where((r) => r.emoji != emoji).toList();
        return msg.copyWith(reactions: reactions);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void addTagToMessage(String messageId, String tag) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        final tags = msg.tags.contains(tag) ? msg.tags : [...msg.tags, tag];
        return msg.copyWith(tags: tags);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  void removeTagFromMessage(String messageId, String tag) {
    if (_currentConversation == null) return;

    final updatedMessages = _currentConversation!.messages.map((msg) {
      if (msg.id == messageId) {
        final tags = msg.tags.where((t) => t != tag).toList();
        return msg.copyWith(tags: tags);
      }
      return msg;
    }).toList();

    _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
    _updateConversation(_currentConversation!);
    _saveConversations();
    notifyListeners();
  }

  Future<void> regenerateMessage(String messageId, ChatModel model) async {
    if (_currentConversation == null) return;

    final messageIndex = _currentConversation!.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final conversationUpToMessage = _currentConversation!.messages.sublist(0, messageIndex);

    deleteMessage(messageId);

    _isLoading = true;
    notifyListeners();

    try {
      final assistantMessage = Message(
        content: '',
        role: MessageRole.assistant,
        isStreaming: true,
      );

      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, assistantMessage],
      );
      _updateConversation(_currentConversation!);
      notifyListeners();

      final responseStream = _openRouterService.sendMessageStream(
        messages: conversationUpToMessage,
        model: model,
      );

      await for (final chunk in responseStream) {
        final updatedMessages = _currentConversation!.messages.map((msg) {
          if (msg.id == assistantMessage.id) {
            return msg.copyWith(content: msg.content + chunk);
          }
          return msg;
        }).toList();

        _currentConversation = _currentConversation!.copyWith(messages: updatedMessages);
        _updateConversation(_currentConversation!);
        notifyListeners();
      }

      final finalMessages = _currentConversation!.messages.map((msg) {
        if (msg.id == assistantMessage.id) {
          return msg.copyWith(isStreaming: false);
        }
        return msg;
      }).toList();

      _currentConversation = _currentConversation!.copyWith(messages: finalMessages);
      _updateConversation(_currentConversation!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      _saveConversations();
    }
  }

  void togglePinConversation(String conversationId) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(isPinned: !conversation.isPinned);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void toggleFavoriteConversation(String conversationId) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(isFavorite: !conversation.isFavorite);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void toggleArchiveConversation(String conversationId) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(isArchived: !conversation.isArchived);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void moveConversationToFolder(String conversationId, String? folder) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(folder: folder);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void addTagToConversation(String conversationId, String tag) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final tags = conversation.tags.contains(tag) 
        ? conversation.tags 
        : [...conversation.tags, tag];
    final updated = conversation.copyWith(tags: tags);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void removeTagFromConversation(String conversationId, String tag) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final tags = conversation.tags.where((t) => t != tag).toList();
    final updated = conversation.copyWith(tags: tags);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void updateConversationColor(String conversationId, int color) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(color: color);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  void updateConversationAvatar(String conversationId, String? avatar) {
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updated = conversation.copyWith(customAvatar: avatar);
    _updateConversation(updated);
    if (_currentConversation?.id == conversationId) {
      _currentConversation = updated;
    }
    _saveConversations();
    notifyListeners();
  }

  List<Message> getPinnedMessages() {
    if (_currentConversation == null) return [];
    return _currentConversation!.messages.where((m) => m.isPinned).toList();
  }

  List<Message> getFavoriteMessages() {
    if (_currentConversation == null) return [];
    return _currentConversation!.messages.where((m) => m.isFavorite).toList();
  }

  List<Conversation> getPinnedConversations() {
    return _conversations.where((c) => c.isPinned).toList();
  }

  List<Conversation> getFavoriteConversations() {
    return _conversations.where((c) => c.isFavorite).toList();
  }

  List<Conversation> getArchivedConversations() {
    return _conversations.where((c) => c.isArchived).toList();
  }
}
