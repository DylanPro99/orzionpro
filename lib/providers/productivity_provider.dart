import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class SearchFilter {
  final String? role;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tags;
  final bool? isPinned;
  final bool? isFavorite;

  SearchFilter({
    this.role,
    this.startDate,
    this.endDate,
    this.tags,
    this.isPinned,
    this.isFavorite,
  });
}

class ProductivityProvider with ChangeNotifier {
  String _searchQuery = '';
  List<String> _folders = [];
  List<String> _allTags = [];
  String? _selectedFolder;
  List<String> _selectedTags = [];
  SearchFilter? _currentFilter;

  String get searchQuery => _searchQuery;
  List<String> get folders => _folders;
  List<String> get allTags => _allTags;
  String? get selectedFolder => _selectedFolder;
  List<String> get selectedTags => _selectedTags;
  SearchFilter? get currentFilter => _currentFilter;

  ProductivityProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _folders = prefs.getStringList('folders') ?? ['General', 'Trabajo', 'Personal', 'Ideas'];
    _allTags = prefs.getStringList('allTags') ?? ['importante', 'pendiente', 'completado'];
    _selectedFolder = prefs.getString('selectedFolder');
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('folders', _folders);
    await prefs.setStringList('allTags', _allTags);
    if (_selectedFolder != null) {
      await prefs.setString('selectedFolder', _selectedFolder!);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSearchFilter(SearchFilter? filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<Message> searchMessages(List<Message> messages) {
    if (_searchQuery.isEmpty && _currentFilter == null) {
      return messages;
    }

    return messages.where((message) {
      bool matchesQuery = _searchQuery.isEmpty ||
          message.content.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesFilter = true;
      if (_currentFilter != null) {
        if (_currentFilter!.role != null &&
            message.role.name != _currentFilter!.role) {
          matchesFilter = false;
        }
        if (_currentFilter!.startDate != null &&
            message.timestamp.isBefore(_currentFilter!.startDate!)) {
          matchesFilter = false;
        }
        if (_currentFilter!.endDate != null &&
            message.timestamp.isAfter(_currentFilter!.endDate!)) {
          matchesFilter = false;
        }
        if (_currentFilter!.tags != null &&
            !_currentFilter!.tags!.any((tag) => message.tags.contains(tag))) {
          matchesFilter = false;
        }
        if (_currentFilter!.isPinned != null &&
            message.isPinned != _currentFilter!.isPinned) {
          matchesFilter = false;
        }
        if (_currentFilter!.isFavorite != null &&
            message.isFavorite != _currentFilter!.isFavorite) {
          matchesFilter = false;
        }
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<Conversation> filterConversations(List<Conversation> conversations) {
    List<Conversation> filtered = conversations;

    if (_selectedFolder != null) {
      filtered = filtered.where((c) => c.folder == _selectedFolder).toList();
    }

    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((c) {
        return _selectedTags.any((tag) => c.tags.contains(tag));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.messages.any((m) =>
                m.content.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  Future<void> addFolder(String folder) async {
    if (!_folders.contains(folder)) {
      _folders.add(folder);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> removeFolder(String folder) async {
    _folders.remove(folder);
    if (_selectedFolder == folder) {
      _selectedFolder = null;
    }
    await _saveData();
    notifyListeners();
  }

  void selectFolder(String? folder) {
    _selectedFolder = folder;
    notifyListeners();
  }

  Future<void> addTag(String tag) async {
    if (!_allTags.contains(tag)) {
      _allTags.add(tag);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> removeTag(String tag) async {
    _allTags.remove(tag);
    _selectedTags.remove(tag);
    await _saveData();
    notifyListeners();
  }

  void toggleTagSelection(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _currentFilter = null;
    notifyListeners();
  }

  void clearFilters() {
    _selectedFolder = null;
    _selectedTags.clear();
    _currentFilter = null;
    notifyListeners();
  }
}
