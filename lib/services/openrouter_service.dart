import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/chat_model.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _imageGenModel = 'black-forest-labs/flux-1.1-pro';
  
  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String _convertBytesToBase64(Uint8List bytes, {String? imagePath}) {
    try {
      final base64String = base64Encode(bytes);
      
      String mimeType = 'image/jpeg';
      if (imagePath != null) {
        if (imagePath.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (imagePath.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (imagePath.toLowerCase().endsWith('.webp')) {
          mimeType = 'image/webp';
        }
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Error al convertir imagen a base64: $e');
    }
  }

  Stream<String> sendMessageStream({
    required List<Message> messages,
    required ChatModel model,
    List<Uint8List>? imageBytes,
  }) async* {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API Key de OpenRouter no configurada. Por favor, añade tu API Key en la configuración.');
    }

    final messagesJson = messages.map((msg) {
      final messageContent = <Map<String, dynamic>>[];
      
      if (msg.imageBytes != null && msg.imageBytes!.isNotEmpty) {
        for (int i = 0; i < msg.imageBytes!.length; i++) {
          final bytes = msg.imageBytes![i];
          final imagePath = msg.imageUrls != null && i < msg.imageUrls!.length 
              ? msg.imageUrls![i] 
              : null;
          
          final imageData = _convertBytesToBase64(bytes, imagePath: imagePath);
          
          messageContent.add({
            'type': 'image_url',
            'image_url': {'url': imageData},
          });
        }
      } else if (msg.imageUrls != null && msg.imageUrls!.isNotEmpty) {
        for (final imageUrl in msg.imageUrls!) {
          if (imageUrl.startsWith('http://') || 
              imageUrl.startsWith('https://') || 
              imageUrl.startsWith('data:')) {
            messageContent.add({
              'type': 'image_url',
              'image_url': {'url': imageUrl},
            });
          }
        }
      }
      
      messageContent.add({
        'type': 'text',
        'text': msg.content,
      });

      return {
        'role': msg.role.name,
        'content': messageContent.length == 1 ? msg.content : messageContent,
      };
    }).toList();

    if (model.type == OrzionModel.pro) {
      final firstModel = model.openRouterModels[0];
      final secondModel = model.openRouterModels.length > 1 
          ? model.openRouterModels[1] 
          : firstModel;

      final firstResponse = StringBuffer();
      final firstStream = _streamFromModel(firstModel, messagesJson, model.systemPrompt);
      
      await for (final chunk in firstStream) {
        firstResponse.write(chunk);
        yield chunk;
      }

      yield '\n\n---\n\n';

      final enhancedMessages = [
        ...messagesJson,
        {
          'role': 'assistant',
          'content': firstResponse.toString(),
        },
        {
          'role': 'user',
          'content': 'Mejora y expande la respuesta anterior con más detalles y profundidad.',
        },
      ];

      await for (final chunk in _streamFromModel(secondModel, enhancedMessages, model.systemPrompt)) {
        yield chunk;
      }
    } else {
      await for (final chunk in _streamFromModel(
        model.openRouterModels[0],
        messagesJson,
        model.systemPrompt,
      )) {
        yield chunk;
      }
    }
  }

  Stream<String> _streamFromModel(
    String modelId,
    List<Map<String, dynamic>> messages,
    String systemPrompt,
  ) async* {
    final messagesWithSystem = [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://orzion.ai',
        'X-Title': 'Orzion',
      },
      body: jsonEncode({
        'model': modelId,
        'messages': messagesWithSystem,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 4000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error en OpenRouter: ${response.statusCode} - ${response.body}');
    }

    final lines = response.body.split('\n');
    for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data.trim() == '[DONE]') break;
        
        try {
          final json = jsonDecode(data);
          final content = json['choices']?[0]?['delta']?['content'];
          if (content != null) {
            yield content as String;
          }
        } catch (e) {
          continue;
        }
      }
    }
  }

  Future<String> generateImage(String prompt) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API Key de OpenRouter no configurada');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://orzion.ai',
        'X-Title': 'Orzion',
      },
      body: jsonEncode({
        'model': _imageGenModel,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error generando imagen: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final imageUrl = json['choices']?[0]?['message']?['content'];
    
    if (imageUrl == null) {
      throw Exception('No se pudo generar la imagen');
    }

    return imageUrl as String;
  }
}
