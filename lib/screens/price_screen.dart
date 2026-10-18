import 'dart:async';
import 'package:flutter/material.dart';

import '../data/price_tick.dart';
import '../services/price_service.dart';
import '../services/stream_operators.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  final _service = PriceService();
  final _searchInput = StreamController<String>();
  late final StreamSubscription<String> _searchSub;
  late final Future<Map<String, double>> _initial;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Future: tải giá ban đầu xong mới bắt đầu phát Stream
    _initial = _service.loadInitialPrices().then((prices) {
      _service.start();
      return prices;
    });
    // Stream + debounce: chờ người dùng gõ xong 300ms mới lọc
    _searchSub = _searchInput.stream
        .transform(debounce(const Duration(milliseconds: 300)))
        .listen((q) => setState(() => _query = q.trim().toUpperCase()));
  }

  // Bước 10: hủy luồng an toàn khi thoát màn hình
  @override
  void dispose() {
    _searchSub.cancel();
    _searchInput.close();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giá thời gian thực')),
      body: FutureBuilder<Map<String, double>>(
        future: _initial,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final initial = snap.data!;
          final symbols =
              initial.keys.where((s) => s.contains(_query)).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Tìm mã (BTC, ETH...)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _searchInput.add,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final s in symbols)
                      PriceTile(
                        key: ValueKey(s),
                        symbol: s,
                        initialPrice: initial[s]!,
                        stream: _service.watch(s),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PriceTile extends StatelessWidget {
  const PriceTile({
    super.key,
    required this.symbol,
    required this.initialPrice,
    required this.stream,
  });

  final String symbol;
  final double initialPrice;
  final Stream<PriceTick> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PriceTick>(
      stream: stream,
      builder: (context, snap) {
        final tick = snap.data;
        final price = tick?.price ?? initialPrice;
        final up = tick?.isUp ?? true;
        final color = up ? Colors.green : Colors.red;
        return ListTile(
          title: Text(symbol,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price.toStringAsFixed(2),
                  style: TextStyle(color: color, fontSize: 18)),
              if (tick != null)
                Text('${up ? '▲' : '▼'} ${tick.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(color: color)),
            ],
          ),
        );
      },
    );
  }
}