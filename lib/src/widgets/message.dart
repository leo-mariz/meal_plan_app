import 'package:flutter/material.dart';

class IntermediateMessage extends StatelessWidget {
  final String message;
  final VoidCallback onButtonPressed;

  const IntermediateMessage({
    required this.message,
    required this.onButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: const Text('Preencher'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
