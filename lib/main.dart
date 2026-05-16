import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const VyshuContentStudio());
}

class VyshuContentStudio extends StatelessWidget {
  const VyshuContentStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vyshu Content Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF0F0F1A),
        ),
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
