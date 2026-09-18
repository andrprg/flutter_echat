import 'package:flutter/material.dart';

import 'utils/theme/theme.dart';

/// Корневой виджет приложения E-Chat.
class EChatApp extends StatelessWidget {
  const EChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Chat',
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('E-Chat'),
        ),
      ),
    );
  }
}
