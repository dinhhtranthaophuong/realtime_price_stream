import 'dart:async';
import 'package:flutter/material.dart';

import 'services/price_service.dart';
import 'services/stream_operators.dart';

void main() {
  final service = PriceService();
  final subs = <StreamSubscription>[];

  // map + transform: trung bình trượt 5 điểm của BTC
  subs.add(
    service
        .priceOf('BTC')
        .transform(movingAverage(5))
        .listen((v) => debugPrint('BTC MA5: ${v.toStringAsFixed(2)}')),
  );

  // where: biến động mạnh (đặt threshold 0.2 để dễ quan sát thấy dòng log)
  subs.add(
    service.bigMoves(thresholdPercent: 0.2).listen(
          (t) => debugPrint(
              'BIẾN ĐỘNG MẠNH ${t.symbol}: ${t.changePercent.toStringAsFixed(2)}%'),
        ),
  );

  // debounce: giả lập gõ nhanh "B" -> "BT" -> "BTC"
  final search = StreamController<String>();
  subs.add(
    search.stream
        .transform(debounce(const Duration(milliseconds: 300)))
        .listen((q) => debugPrint('TÌM KIẾM: $q')),
  );
  search
    ..add('B')
    ..add('BT')
    ..add('BTC');

  service.start();

  Future.delayed(const Duration(seconds: 5), () async {
    for (final s in subs) {
      await s.cancel();
    }
    await search.close();
    await service.dispose();
    debugPrint('Đã hủy toàn bộ luồng');
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
          child: Text('Đang test toán tử Stream & Debounce trên console...'),
        ),
      ),
    );
  }
}