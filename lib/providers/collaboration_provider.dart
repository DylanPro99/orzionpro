import 'package:flutter/material.dart';
import '../services/collaboration_service.dart';
import '../services/export_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class CollaborationProvider with ChangeNotifier {
  final CollaborationService _collaborationService = CollaborationService();
  final ExportService _exportService = ExportService();

  List<Template> get templates => _collaborationService.templates;

  Future<void> shareConversation(Conversation conversation) async {
    await _collaborationService.shareConversation(conversation);
  }

  String generateQRCode(String data) {
    return _collaborationService.generateQRCode(data);
  }

  Future<Conversation?> importConversation(String encodedData) async {
    return await _collaborationService.importConversation(encodedData);
  }

  Template? getTemplateById(String id) {
    return _collaborationService.getTemplateById(id);
  }

  List<Template> searchTemplates(String query) {
    return _collaborationService.searchTemplates(query);
  }

  Future<void> exportToPDF(Conversation conversation) async {
    await _exportService.exportConversationToPDF(conversation);
  }

  Future<void> exportToJSON(Conversation conversation) async {
    await _exportService.exportConversationToJSON(conversation);
  }

  Future<void> exportToText(Conversation conversation) async {
    await _exportService.exportConversationToText(conversation);
  }

  Future<void> copyMessageToClipboard(Message message) async {
    await _exportService.exportMessageToClipboard(message);
  }
}
