import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationProvider with ChangeNotifier {
  double _fontSize = 16.0;
  String _fontFamily = 'Roboto';
  Color _primaryColor = const Color(0xFF6C63FF);
  Color _accentColor = const Color(0xFF4CAF50);
  String? _userAvatar;
  String _userName = 'Usuario';
  bool _compactMode = false;
  bool _showTimestamps = true;
  bool _showAvatars = true;
  bool _enableAnimations = true;
  bool _enableHaptics = true;
  bool _enableSoundEffects = false;
  double _messageSpacing = 8.0;
  double _bubbleRadius = 16.0;

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  String? get userAvatar => _userAvatar;
  String get userName => _userName;
  bool get compactMode => _compactMode;
  bool get showTimestamps => _showTimestamps;
  bool get showAvatars => _showAvatars;
  bool get enableAnimations => _enableAnimations;
  bool get enableHaptics => _enableHaptics;
  bool get enableSoundEffects => _enableSoundEffects;
  double get messageSpacing => _messageSpacing;
  double get bubbleRadius => _bubbleRadius;

  PersonalizationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Roboto';
    _primaryColor = Color(prefs.getInt('primaryColor') ?? 0xFF6C63FF);
    _accentColor = Color(prefs.getInt('accentColor') ?? 0xFF4CAF50);
    _userAvatar = prefs.getString('userAvatar');
    _userName = prefs.getString('userName') ?? 'Usuario';
    _compactMode = prefs.getBool('compactMode') ?? false;
    _showTimestamps = prefs.getBool('showTimestamps') ?? true;
    _showAvatars = prefs.getBool('showAvatars') ?? true;
    _enableAnimations = prefs.getBool('enableAnimations') ?? true;
    _enableHaptics = prefs.getBool('enableHaptics') ?? true;
    _enableSoundEffects = prefs.getBool('enableSoundEffects') ?? false;
    _messageSpacing = prefs.getDouble('messageSpacing') ?? 8.0;
    _bubbleRadius = prefs.getDouble('bubbleRadius') ?? 16.0;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', family);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', color.value);
    notifyListeners();
  }

  Future<void> setUserAvatar(String? path) async {
    _userAvatar = path;
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('userAvatar', path);
    } else {
      await prefs.remove('userAvatar');
    }
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> setCompactMode(bool value) async {
    _compactMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compactMode', value);
    notifyListeners();
  }

  Future<void> setShowTimestamps(bool value) async {
    _showTimestamps = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTimestamps', value);
    notifyListeners();
  }

  Future<void> setShowAvatars(bool value) async {
    _showAvatars = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAvatars', value);
    notifyListeners();
  }

  Future<void> setEnableAnimations(bool value) async {
    _enableAnimations = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableAnimations', value);
    notifyListeners();
  }

  Future<void> setEnableHaptics(bool value) async {
    _enableHaptics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableHaptics', value);
    notifyListeners();
  }

  Future<void> setEnableSoundEffects(bool value) async {
    _enableSoundEffects = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableSoundEffects', value);
    notifyListeners();
  }

  Future<void> setMessageSpacing(double value) async {
    _messageSpacing = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('messageSpacing', value);
    notifyListeners();
  }

  Future<void> setBubbleRadius(double value) async {
    _bubbleRadius = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bubbleRadius', value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadPreferences();
  }
}
