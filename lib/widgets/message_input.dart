import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MessageInput extends StatefulWidget {
  final Function(String content, List<String>? imagePaths, List<Uint8List>? imageBytes, List<String>? files) onSendMessage;

  const MessageInput({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _selectedImagePaths = [];
  final List<Uint8List> _selectedImageBytes = [];
  final List<String> _selectedFiles = [];
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImagePaths.add(pickedFile.path);
        _selectedImageBytes.add(bytes);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFiles.add(result.files.single.path!);
      });
    }
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImagePaths.isEmpty && _selectedFiles.isEmpty) return;

    widget.onSendMessage(
      text,
      _selectedImagePaths.isNotEmpty ? _selectedImagePaths : null,
      _selectedImageBytes.isNotEmpty ? _selectedImageBytes : null,
      _selectedFiles.isNotEmpty ? _selectedFiles : null,
    );

    _controller.clear();
    setState(() {
      _selectedImagePaths.clear();
      _selectedImageBytes.clear();
      _selectedFiles.clear();
      _isComposing = false;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF343541) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImagePaths.isNotEmpty || _selectedFiles.isNotEmpty)
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImagePaths.length + _selectedFiles.length,
                itemBuilder: (context, index) {
                  if (index < _selectedImagePaths.length) {
                    final imageBytes = _selectedImageBytes[index];
                    return _buildAttachmentPreview(
                      context,
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                      onRemove: () {
                        setState(() {
                          _selectedImagePaths.removeAt(index);
                          _selectedImageBytes.removeAt(index);
                        });
                      },
                    );
                  } else {
                    final fileIndex = index - _selectedImagePaths.length;
                    final filePath = _selectedFiles[fileIndex];
                    return _buildAttachmentPreview(
                      context,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insert_drive_file, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            filePath.split('/').last,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onRemove: () {
                        setState(() {
                          _selectedFiles.removeAt(fileIndex);
                        });
                      },
                    );
                  }
                },
              ),
            ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined),
                onPressed: _pickImage,
                color: theme.primaryColor,
              ),
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFile,
                color: theme.primaryColor,
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF40414F)
                          : const Color(0xFFF7F7F8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isComposing || _selectedImagePaths.isNotEmpty || _selectedFiles.isNotEmpty
                        ? Icons.send
                        : Icons.mic,
                    color: Colors.white,
                  ),
                  onPressed: _handleSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(
    BuildContext context, {
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
