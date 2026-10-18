import 'package:flutter/material.dart';
import 'screens/price_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Realtime Price Stream',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Trang chủ')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PriceScreen()),
            ),
            child: const Text('Mở bảng giá'),
          ),
        ),
      );
}