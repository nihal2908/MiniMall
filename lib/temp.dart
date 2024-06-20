import 'package:flutter/material.dart';
import 'package:mnnit/pages/home_page.dart';
import 'package:mnnit/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
            home: HomePage(),
          );
        },
      ),
    );
  }
}
