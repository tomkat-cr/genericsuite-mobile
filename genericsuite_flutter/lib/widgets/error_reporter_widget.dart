// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genericsuite/widgets/back_button.dart';

const showScaffold = true;

class ErrorReporter extends StatelessWidget {
  final String message;

  const ErrorReporter({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    var errorMessage = "Error: $message";
    if (showScaffold) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return const Text('');
    } else {
      return Column(children: <Widget>[const ButtonBack(), Text(errorMessage)]);
    }
  }
}
