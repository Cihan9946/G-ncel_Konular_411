import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const DerinDenizApp());
}

class DerinDenizApp extends StatelessWidget {
  const DerinDenizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'Derin Deniz Altı Mürettebatı',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
