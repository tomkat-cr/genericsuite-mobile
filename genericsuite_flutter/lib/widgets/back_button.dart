import 'package:flutter/material.dart';

class ButtonBack extends StatelessWidget {
  const ButtonBack({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: const Text('Back'),
    );
  }
}
