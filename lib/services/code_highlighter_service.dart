import 'package:flutter/material.dart';

class CodeHighlighterService {
  static const Map<String, Color> _syntaxColors = {
    'keyword': Color(0xFFCF8E6D),
    'string': Color(0xFF6AAB73),
    'comment': Color(0xFF808080),
    'function': Color(0xFF56A8F5),
    'number': Color(0xFF2AACB8),
    'operator': Color(0xFFCC7832),
    'variable': Color(0xFF9876AA),
  };

  static const Map<String, List<String>> _languageKeywords = {
    'dart': [
      'class',
      'abstract',
      'extends',
      'implements',
      'import',
      'library',
      'void',
      'var',
      'final',
      'const',
      'static',
      'async',
      'await',
      'return',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'throw',
      'new',
      'this',
      'super',
      'true',
      'false',
      'null',
    ],
    'javascript': [
      'function',
      'const',
      'let',
      'var',
      'class',
      'extends',
      'import',
      'export',
      'default',
      'async',
      'await',
      'return',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'break',
      'continue',
      'try',
      'catch',
      'throw',
      'new',
      'this',
      'super',
      'true',
      'false',
      'null',
      'undefined',
    ],
    'python': [
      'def',
      'class',
      'import',
      'from',
      'as',
      'return',
      'if',
      'elif',
      'else',
      'for',
      'while',
      'break',
      'continue',
      'try',
      'except',
      'finally',
      'raise',
      'with',
      'async',
      'await',
      'lambda',
      'yield',
      'True',
      'False',
      'None',
      'and',
      'or',
      'not',
      'in',
      'is',
    ],
  };

  static String detectLanguage(String code) {
    final lowerCode = code.toLowerCase();
    
    if (lowerCode.contains('import \'package:') || lowerCode.contains('class ') && lowerCode.contains('extends')) {
      return 'dart';
    }
    if (lowerCode.contains('function ') || lowerCode.contains('const ') || lowerCode.contains('=>')) {
      return 'javascript';
    }
    if (lowerCode.contains('def ') || lowerCode.contains('import ') && lowerCode.contains('from ')) {
      return 'python';
    }
    if (lowerCode.contains('public class') || lowerCode.contains('private void')) {
      return 'java';
    }
    
    return 'text';
  }

  static bool isCodeBlock(String text) {
    return text.contains('```') || 
           text.contains('    ') && text.split('\n').length > 3 ||
           RegExp(r'^(function|class|def|public|private|const|let|var)\s').hasMatch(text.trim());
  }

  static List<TextSpan> highlightCode(String code, String language) {
    if (language == 'text') {
      return [TextSpan(text: code, style: const TextStyle(fontFamily: 'monospace'))];
    }

    final keywords = _languageKeywords[language] ?? [];
    final spans = <TextSpan>[];
    final lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_highlightLine(line, keywords));
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  static List<TextSpan> _highlightLine(String line, List<String> keywords) {
    final spans = <TextSpan>[];
    
    if (line.trim().startsWith('//') || line.trim().startsWith('#')) {
      return [
        TextSpan(
          text: line,
          style: TextStyle(
            color: _syntaxColors['comment'],
            fontFamily: 'monospace',
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    final stringPattern = RegExp(r'(["\'])((?:\\\1|(?:(?!\1).))*)\1');
    final numberPattern = RegExp(r'\b\d+(\.\d+)?\b');
    final functionPattern = RegExp(r'\b([a-zA-Z_]\w*)\s*\(');

    var currentIndex = 0;
    final tokens = <MapEntry<int, String>>[];

    stringPattern.allMatches(line).forEach((match) {
      tokens.add(MapEntry(match.start, 'string:${match.group(0)}'));
    });

    numberPattern.allMatches(line).forEach((match) {
      tokens.add(MapEntry(match.start, 'number:${match.group(0)}'));
    });

    functionPattern.allMatches(line).forEach((match) {
      tokens.add(MapEntry(match.start, 'function:${match.group(1)}'));
    });

    for (final keyword in keywords) {
      final pattern = RegExp(r'\b' + keyword + r'\b');
      pattern.allMatches(line).forEach((match) {
        tokens.add(MapEntry(match.start, 'keyword:${match.group(0)}'));
      });
    }

    tokens.sort((a, b) => a.key.compareTo(b.key));

    for (final token in tokens) {
      if (token.key > currentIndex) {
        spans.add(TextSpan(
          text: line.substring(currentIndex, token.key),
          style: const TextStyle(fontFamily: 'monospace'),
        ));
      }

      final parts = token.value.split(':');
      final type = parts[0];
      final value = parts.length > 1 ? parts[1] : '';

      spans.add(TextSpan(
        text: value,
        style: TextStyle(
          color: _syntaxColors[type] ?? Colors.white,
          fontFamily: 'monospace',
          fontWeight: type == 'keyword' ? FontWeight.bold : FontWeight.normal,
        ),
      ));

      currentIndex = token.key + value.length;
    }

    if (currentIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentIndex),
        style: const TextStyle(fontFamily: 'monospace'),
      ));
    }

    return spans;
  }

  static String getLanguageName(String languageCode) {
    const names = {
      'dart': 'Dart',
      'javascript': 'JavaScript',
      'python': 'Python',
      'java': 'Java',
      'cpp': 'C++',
      'c': 'C',
      'rust': 'Rust',
      'go': 'Go',
      'swift': 'Swift',
      'kotlin': 'Kotlin',
      'typescript': 'TypeScript',
      'html': 'HTML',
      'css': 'CSS',
      'sql': 'SQL',
      'bash': 'Bash',
      'json': 'JSON',
      'yaml': 'YAML',
    };

    return names[languageCode.toLowerCase()] ?? languageCode.toUpperCase();
  }
}
