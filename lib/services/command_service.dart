import 'package:flutter/foundation.dart';

enum CommandType {
  clear,
  help,
  export,
  summarize,
  translate,
  improve,
  explain,
  code,
  image,
  voice,
}

class Command {
  final CommandType type;
  final String trigger;
  final String description;
  final String usage;
  final List<String> aliases;

  const Command({
    required this.type,
    required this.trigger,
    required this.description,
    required this.usage,
    this.aliases = const [],
  });
}

class CommandService {
  static final Map<String, Command> _commands = {
    '/clear': Command(
      type: CommandType.clear,
      trigger: '/clear',
      description: 'Limpia la conversación actual',
      usage: '/clear',
      aliases: ['/c', '/borrar'],
    ),
    '/help': Command(
      type: CommandType.help,
      trigger: '/help',
      description: 'Muestra la lista de comandos disponibles',
      usage: '/help',
      aliases: ['/h', '/ayuda', '/?'],
    ),
    '/export': Command(
      type: CommandType.export,
      trigger: '/export',
      description: 'Exporta la conversación actual',
      usage: '/export [pdf|json|txt]',
      aliases: ['/e', '/exportar'],
    ),
    '/summarize': Command(
      type: CommandType.summarize,
      trigger: '/summarize',
      description: 'Genera un resumen de la conversación',
      usage: '/summarize',
      aliases: ['/sum', '/resumen'],
    ),
    '/translate': Command(
      type: CommandType.translate,
      trigger: '/translate',
      description: 'Traduce el último mensaje',
      usage: '/translate [idioma]',
      aliases: ['/tr', '/traducir'],
    ),
    '/improve': Command(
      type: CommandType.improve,
      trigger: '/improve',
      description: 'Mejora el último mensaje',
      usage: '/improve',
      aliases: ['/mejorar'],
    ),
    '/explain': Command(
      type: CommandType.explain,
      trigger: '/explain',
      description: 'Explica el último código o concepto',
      usage: '/explain',
      aliases: ['/exp', '/explicar'],
    ),
    '/code': Command(
      type: CommandType.code,
      trigger: '/code',
      description: 'Genera código con la descripción dada',
      usage: '/code [descripción]',
      aliases: ['/codigo'],
    ),
    '/image': Command(
      type: CommandType.image,
      trigger: '/image',
      description: 'Genera una imagen con la descripción dada',
      usage: '/image [descripción]',
      aliases: ['/img', '/imagen'],
    ),
    '/voice': Command(
      type: CommandType.voice,
      trigger: '/voice',
      description: 'Activa la entrada por voz',
      usage: '/voice',
      aliases: ['/v', '/voz'],
    ),
  };

  static List<Command> getAllCommands() {
    return _commands.values.toList();
  }

  static Command? parseCommand(String input) {
    final trimmed = input.trim().toLowerCase();
    
    for (final entry in _commands.entries) {
      if (trimmed.startsWith(entry.key)) {
        return entry.value;
      }
      
      for (final alias in entry.value.aliases) {
        if (trimmed.startsWith(alias)) {
          return entry.value;
        }
      }
    }
    
    return null;
  }

  static String? extractArguments(String input) {
    final command = parseCommand(input);
    if (command == null) return null;
    
    final trimmed = input.trim();
    String trigger = command.trigger;
    
    if (!trimmed.toLowerCase().startsWith(trigger)) {
      for (final alias in command.aliases) {
        if (trimmed.toLowerCase().startsWith(alias)) {
          trigger = alias;
          break;
        }
      }
    }
    
    if (trimmed.length > trigger.length) {
      return trimmed.substring(trigger.length).trim();
    }
    
    return null;
  }

  static String getHelpText() {
    final buffer = StringBuffer();
    buffer.writeln('# 🤖 Comandos Disponibles\n');
    
    for (final command in _commands.values) {
      buffer.writeln('## ${command.trigger}');
      buffer.writeln(command.description);
      buffer.writeln('**Uso:** `${command.usage}`');
      
      if (command.aliases.isNotEmpty) {
        buffer.writeln('**Alias:** ${command.aliases.map((a) => '`$a`').join(', ')}');
      }
      
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  static List<String> getSuggestions(String input) {
    if (!input.startsWith('/')) return [];
    
    final matches = <String>[];
    final lowerInput = input.toLowerCase();
    
    for (final command in _commands.values) {
      if (command.trigger.startsWith(lowerInput)) {
        matches.add(command.trigger);
      }
      
      for (final alias in command.aliases) {
        if (alias.startsWith(lowerInput) && !matches.contains(alias)) {
          matches.add(alias);
        }
      }
    }
    
    return matches;
  }
}
