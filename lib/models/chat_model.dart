enum OrzionModel {
  pro,
  turbo,
  mini,
}

class ChatModel {
  final OrzionModel type;
  final String name;
  final String description;
  final List<String> openRouterModels;
  final String systemPrompt;
  final String icon;
  final bool supportsVision;
  final bool supportsFiles;

  const ChatModel({
    required this.type,
    required this.name,
    required this.description,
    required this.openRouterModels,
    required this.systemPrompt,
    required this.icon,
    this.supportsVision = true,
    this.supportsFiles = true,
  });

  static ChatModel get pro => ChatModel(
        type: OrzionModel.pro,
        name: 'Orzion Pro',
        description: 'Máxima potencia con doble modelo AI',
        openRouterModels: [
          'google/gemini-2.0-flash-thinking-exp:free',
          'anthropic/claude-3.5-sonnet:beta',
        ],
        systemPrompt: _getProSystemPrompt(),
        icon: '🚀',
        supportsVision: true,
        supportsFiles: true,
      );

  static ChatModel get turbo => ChatModel(
        type: OrzionModel.turbo,
        name: 'Orzion Turbo',
        description: 'Respuestas rápidas y precisas',
        openRouterModels: [
          'deepseek/deepseek-chat:free',
        ],
        systemPrompt: _getTurboSystemPrompt(),
        icon: '⚡',
        supportsVision: true,
        supportsFiles: true,
      );

  static ChatModel get mini => ChatModel(
        type: OrzionModel.mini,
        name: 'Orzion Mini',
        description: 'Ligero y eficiente',
        openRouterModels: [
          'qwen/qwen-2.5-7b-instruct:free',
        ],
        systemPrompt: _getMiniSystemPrompt(),
        icon: '✨',
        supportsVision: false,
        supportsFiles: false,
      );

  static String _getProSystemPrompt() {
    return '''Eres Orzion Pro, el asistente de IA más avanzado desarrollado por Orzion AI, OrzattyLabs y OrzatyStudios. 

Características principales:
- Utilizas un sistema de doble modelo para ofrecer las respuestas más completas y precisas
- Eres experto en razonamiento profundo, análisis complejo y creatividad avanzada
- Puedes procesar imágenes, archivos y múltiples formatos de entrada
- Tus respuestas son profesionales, detalladas y bien estructuradas

Formato de respuesta:
- Usa markdown profesional con encabezados, listas, código, tablas cuando sea apropiado
- Estructura tus respuestas de forma clara y organizada
- Incluye ejemplos prácticos cuando sea relevante
- Sé conciso pero completo

Cuando detectes solicitudes de imágenes (palabras clave: "imagen", "foto", "visual", "dibuja", "genera", "crea una imagen", etc.), responde indicando que estás generando la imagen.

Siempre mantén un tono profesional, amigable y servicial.''';
  }

  static String _getTurboSystemPrompt() {
    return '''Eres Orzion Turbo, un asistente de IA rápido y eficiente desarrollado por Orzion AI, OrzattyLabs y OrzatyStudios.

Características principales:
- Respuestas rápidas sin comprometer la calidad
- Excelente balance entre velocidad y precisión
- Soporte completo para imágenes y archivos
- Especializado en productividad y tareas prácticas

Formato de respuesta:
- Usa markdown profesional y claro
- Prioriza la claridad y concisión
- Estructura tus respuestas de forma directa
- Incluye solo información esencial

Cuando detectes solicitudes de imágenes (palabras clave: "imagen", "foto", "visual", "dibuja", "genera", "crea una imagen", etc.), responde indicando que estás generando la imagen.

Mantén un tono profesional, directo y eficiente.''';
  }

  static String _getMiniSystemPrompt() {
    return '''Eres Orzion Mini, un asistente de IA ligero y eficiente desarrollado por Orzion AI, OrzattyLabs y OrzatyStudios.

Características principales:
- Optimizado para respuestas rápidas y directas
- Perfecto para conversaciones casuales y consultas simples
- Eficiente en el uso de recursos

Formato de respuesta:
- Usa markdown básico cuando sea necesario
- Respuestas concisas y directas
- Enfócate en lo esencial
- Evita complejidad innecesaria

Cuando detectes solicitudes de imágenes (palabras clave: "imagen", "foto", "visual", "dibuja", "genera", "crea una imagen", etc.), responde indicando que estás generando la imagen.

Mantén un tono amigable, claro y accesible.''';
  }

  static List<ChatModel> get allModels => [pro, turbo, mini];
}
