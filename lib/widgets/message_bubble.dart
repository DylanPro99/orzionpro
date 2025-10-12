import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  bool _isRemoteUrl(String url) {
    return url.startsWith('http://') || 
           url.startsWith('https://') || 
           url.startsWith('data:');
  }

  Widget _buildImageWidget(String? url, Uint8List? bytes, ThemeData theme) {
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: theme.cardColor,
          child: const Icon(Icons.error),
        ),
      );
    } else if (url != null && _isRemoteUrl(url)) {
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => Container(
          height: 200,
          color: theme.cardColor,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: theme.cardColor,
          child: const Icon(Icons.error),
        ),
      );
    } else {
      return Container(
        height: 200,
        color: theme.cardColor,
        child: const Center(
          child: Text('No se pudo cargar la imagen'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context, isDark),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? const Color(0xFF343541) : const Color(0xFFEFEFEF))
                        : (isDark ? const Color(0xFF444654) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageBytes != null && message.imageBytes!.isNotEmpty)
                        ...message.imageBytes!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final bytes = entry.value;
                          final url = message.imageUrls != null && index < message.imageUrls!.length
                              ? message.imageUrls![index]
                              : null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImageWidget(url, bytes, theme),
                            ),
                          );
                        })
                      else if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
                        ...message.imageUrls!.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(url, null, theme),
                              ),
                            )),
                      if (message.content.isNotEmpty)
                        isUser
                            ? Text(
                                message.content,
                                style: theme.textTheme.bodyLarge,
                              )
                            : MarkdownBody(
                                data: message.content,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: theme.textTheme.bodyLarge,
                                  h1: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h2: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h3: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  code: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    backgroundColor: isDark
                                        ? Colors.black26
                                        : Colors.grey[200],
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onTapLink: (text, href, title) {
                                  if (href != null) {
                                    launchUrl(Uri.parse(href));
                                  }
                                },
                              ),
                      if (message.isStreaming)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 300.ms),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUser) _buildAvatar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).primaryColor
            : (isDark ? const Color(0xFF19C37D) : const Color(0xFF10A37F)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.auto_awesome,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
