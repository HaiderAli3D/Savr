import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'nav.dart';
import 'state/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Receipt Saver',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme, // We are primarily using a custom dark-blue look, but this allows system preference if we supported it fully. 
      // Actually, my pages force specific backgorund colors mostly, so themeMode might not matter as much, but good practice.
      themeMode: ThemeMode.dark, // Using dark theme to match the React app
      routerConfig: AppRouter.router,
    );
  }
}
