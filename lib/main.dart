import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const RapMarketApp());
  });
}

class RapMarketApp extends StatelessWidget {
  const RapMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapMarket',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.light,

      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,

        //tipografia
        textTheme: GoogleFonts.urbanistTextTheme(),

        //paleta
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00667C), //turquesa escuro
          brightness: Brightness.light,
          surface: Color(0xFFFFFFFF), //branco
          primary: Color(0xFF00667C), //turquesa escuro
          secondary: Color(0xFF38393A), //cinza escuro
          tertiary: Color(0xFFBBDFE6), //turquesa claro
          error: Color(0xFFBA0404), //vermelho
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00667C), //turquesa escuro
          foregroundColor: Color(0xFFFFFFFF), //branco
          centerTitle: true,
          elevation: 2,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), //branco
      ),

      home: const HomePage(),
    );
  }
}
