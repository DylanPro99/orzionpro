import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/model_provider.dart';
import 'providers/personalization_provider.dart';
import 'providers/productivity_provider.dart';
import 'providers/multimedia_provider.dart';
import 'providers/collaboration_provider.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const OrzionApp());
}

class OrzionApp extends StatelessWidget {
  const OrzionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ModelProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PersonalizationProvider()),
        ChangeNotifierProvider(create: (_) => ProductivityProvider()),
        ChangeNotifierProvider(create: (_) => MultimediaProvider()),
        ChangeNotifierProvider(create: (_) => CollaborationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Orzion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
