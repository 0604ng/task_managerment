// lib/widgets/loading_indicator.dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? text;
  const LoadingIndicator({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (text != null) ...[
          const SizedBox(height: 12),
          Text(text!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }
}
