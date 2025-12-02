import 'package:flutter/material.dart';

class RapMarketPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const RapMarketPage({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: body),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: appBarTheme.backgroundColor ?? theme.primaryColor,
            child: Text(
              "© bySIX",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appBarTheme.foregroundColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
