import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';

class ModelProvider with ChangeNotifier {
  ChatModel _selectedModel = ChatModel.pro;
  
  ChatModel get selectedModel => _selectedModel;

  ModelProvider() {
    _loadSelectedModel();
  }

  Future<void> _loadSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final modelName = prefs.getString('selectedModel') ?? 'pro';
    _selectedModel = ChatModel.allModels.firstWhere(
      (model) => model.type.name == modelName,
      orElse: () => ChatModel.pro,
    );
    notifyListeners();
  }

  Future<void> selectModel(ChatModel model) async {
    _selectedModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedModel', model.type.name);
    notifyListeners();
  }
}
