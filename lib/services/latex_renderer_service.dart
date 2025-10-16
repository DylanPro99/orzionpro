import 'package:flutter/material.dart';

class LaTeXRendererService {
  static bool containsLaTeX(String text) {
    return text.contains(r'$') || 
           text.contains(r'\[') || 
           text.contains(r'\(') ||
           text.contains(r'\begin{') ||
           RegExp(r'\\(frac|sqrt|sum|int|prod|alpha|beta|gamma)').hasMatch(text);
  }

  static List<LaTeXSegment> parseText(String text) {
    final segments = <LaTeXSegment>[];
    
    final inlinePattern = RegExp(r'\$([^\$]+)\$');
    final displayPattern = RegExp(r'\\\[(.+?)\\\]', dotAll: true);
    final environPattern = RegExp(r'\\begin\{(.+?)\}(.+?)\\end\{\1\}', dotAll: true);
    
    var currentIndex = 0;
    final allMatches = <({int start, int end, String latex, LaTeXType type})>[];
    
    for (final match in displayPattern.allMatches(text)) {
      allMatches.add((
        start: match.start,
        end: match.end,
        latex: match.group(1) ?? '',
        type: LaTeXType.display,
      ));
    }
    
    for (final match in environPattern.allMatches(text)) {
      allMatches.add((
        start: match.start,
        end: match.end,
        latex: match.group(2) ?? '',
        type: LaTeXType.environment,
      ));
    }
    
    for (final match in inlinePattern.allMatches(text)) {
      final isAlreadyCovered = allMatches.any((m) => 
        match.start >= m.start && match.end <= m.end
      );
      
      if (!isAlreadyCovered) {
        allMatches.add((
          start: match.start,
          end: match.end,
          latex: match.group(1) ?? '',
          type: LaTeXType.inline,
        ));
      }
    }
    
    allMatches.sort((a, b) => a.start.compareTo(b.start));
    
    for (final match in allMatches) {
      if (match.start > currentIndex) {
        segments.add(LaTeXSegment(
          text: text.substring(currentIndex, match.start),
          type: LaTeXType.text,
        ));
      }
      
      segments.add(LaTeXSegment(
        text: match.latex,
        type: match.type,
      ));
      
      currentIndex = match.end;
    }
    
    if (currentIndex < text.length) {
      segments.add(LaTeXSegment(
        text: text.substring(currentIndex),
        type: LaTeXType.text,
      ));
    }
    
    return segments.isEmpty 
        ? [LaTeXSegment(text: text, type: LaTeXType.text)]
        : segments;
  }

  static String convertToUnicode(String latex) {
    final conversions = {
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\delta': 'δ',
      r'\epsilon': 'ε',
      r'\theta': 'θ',
      r'\lambda': 'λ',
      r'\mu': 'μ',
      r'\pi': 'π',
      r'\sigma': 'σ',
      r'\phi': 'φ',
      r'\omega': 'ω',
      r'\Delta': 'Δ',
      r'\Sigma': 'Σ',
      r'\Omega': 'Ω',
      r'\infty': '∞',
      r'\partial': '∂',
      r'\nabla': '∇',
      r'\int': '∫',
      r'\sum': '∑',
      r'\prod': '∏',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\neq': '≠',
      r'\approx': '≈',
      r'\equiv': '≡',
      r'\pm': '±',
      r'\times': '×',
      r'\div': '÷',
      r'\cdot': '·',
      r'\rightarrow': '→',
      r'\leftarrow': '←',
      r'\Rightarrow': '⇒',
      r'\Leftarrow': '⇐',
    };
    
    var result = latex;
    for (final entry in conversions.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    
    result = result.replaceAll(RegExp(r'\\frac\{([^\}]+)\}\{([^\}]+)\}'), '($1/$2)');
    result = result.replaceAll(RegExp(r'\\sqrt\{([^\}]+)\}'), '√($1)');
    result = result.replaceAll(RegExp(r'\^(\w)'), '⁰¹²³⁴⁵⁶⁷⁸⁹'[int.tryParse(r'$1') ?? 0]);
    result = result.replaceAll(RegExp(r'_(\w)'), '₀₁₂₃₄₅₆₇₈₉'[int.tryParse(r'$1') ?? 0]);
    
    return result;
  }
}

enum LaTeXType {
  text,
  inline,
  display,
  environment,
}

class LaTeXSegment {
  final String text;
  final LaTeXType type;

  LaTeXSegment({
    required this.text,
    required this.type,
  });
}
