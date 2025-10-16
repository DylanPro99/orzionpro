import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ExportService {
  Future<void> exportConversationToPDF(Conversation conversation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(conversation.title,
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          ...conversation.messages.map((message) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    message.role == MessageRole.user ? 'Usuario' : 'Asistente',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(message.content),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    message.timestamp.toString(),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${conversation.title}.pdf',
    );
  }

  Future<void> exportConversationToJSON(Conversation conversation) async {
    final jsonString = jsonEncode(conversation.toJson());
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${conversation.title}.json');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles([XFile(file.path)],
        text: 'Conversación: ${conversation.title}');
  }

  Future<void> exportConversationToText(Conversation conversation) async {
    final buffer = StringBuffer();
    buffer.writeln('=== ${conversation.title} ===\n');
    buffer.writeln('Fecha de creación: ${conversation.createdAt}\n');
    buffer.writeln('Modelo: ${conversation.model.name}\n');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final message in conversation.messages) {
      buffer.writeln('${message.role == MessageRole.user ? "👤 Usuario" : "🤖 Asistente"}:');
      buffer.writeln(message.content);
      buffer.writeln('⏰ ${message.timestamp}');
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${conversation.title}.txt');
    await file.writeAsString(buffer.toString());
    
    await Share.shareXFiles([XFile(file.path)],
        text: 'Conversación: ${conversation.title}');
  }

  Future<void> exportMessageToClipboard(Message message) async {
    await Share.share(message.content);
  }
}
