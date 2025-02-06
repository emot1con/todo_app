import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, var data){
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(data),
    ),
  );
}