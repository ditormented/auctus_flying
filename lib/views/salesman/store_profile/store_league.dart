import 'package:flutter/material.dart';

class StoreLeauge extends StatefulWidget {
  const StoreLeauge({super.key});

  @override
  State<StoreLeauge> createState() => _StoreLeaugeState();
}

class _StoreLeaugeState extends State<StoreLeauge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Store League',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
      ),
    );
  }
}
