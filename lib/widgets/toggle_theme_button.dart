import 'package:flutter/material.dart';
import 'package:mnnit/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ToggleThemeButton extends StatefulWidget {
  const ToggleThemeButton({super.key});

  @override
  State<ToggleThemeButton> createState() => _ToggleThemeButtonState();
}

class _ToggleThemeButtonState extends State<ToggleThemeButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, value, child) => IconButton(
        onPressed: () {
          
        },
        icon: value.thememode == ThemeMode.dark
            ? const Icon(Icons.dark_mode)
            : const Icon(Icons.light_mode),
      ),
    );
  }
}
