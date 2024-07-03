import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String mainTitle;
  final String subtitle;

  const PageTitle({
    required this.mainTitle,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          mainTitle,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class HomePageTitles extends StatelessWidget {
  final String title;

  const HomePageTitles({
    required this.title,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title,
                style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                ));
  }
}
