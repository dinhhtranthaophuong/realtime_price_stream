import 'package:flutter/material.dart';
import 'services/price_service.dart';

void main() {
  final service = PriceService();
  final sub = service.stream.listen((t) {
    debugPrint('${t.symbol}: ${t.price.toStringAsFixed(2)}');
  });
  service.start();

  // sau 5 giây: hủy luồng an toàn
  Future.delayed(const Duration(seconds: 5), () async {
    await sub.cancel();
    await service.dispose();
    debugPrint('Đã hủy luồng');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Đang test PriceStream trên console...'),
        ),
      ),
    );
  }
}