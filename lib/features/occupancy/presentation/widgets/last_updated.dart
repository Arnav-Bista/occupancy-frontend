import 'package:flutter/material.dart';

class LastUpdated extends StatefulWidget {
  const LastUpdated({super.key, required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  State<LastUpdated> createState() => _LastUpdatedState();
}

class _LastUpdatedState extends State<LastUpdated> {
  @override
  Widget build(BuildContext context) {
    return Text("HI");
  }
}
