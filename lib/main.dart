import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase_options.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/pages/login_page.dart';
import 'package:mnnit/pages/splash.dart';
import 'package:provider/provider.dart';
import 'package:mnnit/pages/home_page.dart';
import 'package:mnnit/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ThemeProvider())],
      child: Consumer<ThemeProvider>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
                primaryColor:
                    Colors.deepPurple, // Background color for Scaffold
                scaffoldBackgroundColor: Colors.deepPurple,
                appBarTheme: const AppBarTheme(
                  iconTheme: IconThemeData(
                      color: Colors
                          .white), // White foreground color for AppBar icons
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                ),
                cardColor: Colors.grey.shade200),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor:
                  Colors.black, // Background color for Scaffold in dark mode
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(
                    color: Colors
                        .white), // White foreground color for AppBar icons in dark mode
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              cardColor: Colors.grey.shade700,
              //brightness: Brightness.dark
            ),
            themeMode: themeModel.thememode,
            // home: const SplashScreen()
            home: LoginPage(),
            // home: HomePage(),
            // home: LandingPage(),
          );
        },
      ),
    );
  }
}
