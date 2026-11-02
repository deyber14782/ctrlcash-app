import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ArticleViewPage extends StatelessWidget {
  final String title;
  final String body;
  const ArticleViewPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.3,
            colors: [AppColors.surfaceElevated, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 20),
                      Text(body,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}