import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/price_tick.dart';

class PriceService {
  PriceService({
    Duration interval = const Duration(milliseconds: 500),
    this.live = false,
  }) : _interval = interval;

  final Duration _interval;
  final bool live;
  final Random _random = Random();

  // broadcast: cho phép NHIỀU listener cùng lắng nghe một luồng
  final StreamController<PriceTick> _controller =
      StreamController<PriceTick>.broadcast();

  final Map<String, double> _prices = {
    'BTC': 65000,
    'ETH': 3200,
    'SOL': 150,
    'BNB': 580,
  };

  Timer? _timer;
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;

  Stream<PriceTick> get stream => _controller.stream;

  /// where: lọc theo mã
  Stream<PriceTick> watch(String symbol) =>
      stream.where((t) => t.symbol == symbol);

  /// map: chuyển PriceTick -> double
  Stream<double> priceOf(String symbol) => watch(symbol).map((t) => t.price);

  /// where: chỉ lấy các lần biến động mạnh
  Stream<PriceTick> bigMoves({double thresholdPercent = 0.3}) =>
      stream.where((t) => t.changePercent.abs() >= thresholdPercent);

  bool get isRunning => (_timer?.isActive ?? false) || _wsSub != null;

  /// Future + async/await: ở chế độ live thì gọi REST thật từ Binance
  Future<Map<String, double>> loadInitialPrices() async {
    if (!live) {
      await Future.delayed(const Duration(seconds: 1));
      return Map.of(_prices);
    }
    final results = await Future.wait(_prices.keys.map((s) async {
      final res = await http.get(Uri.parse(
          'https://api.binance.com/api/v3/ticker/price?symbol=${s}USDT'));
      final price = double.parse(jsonDecode(res.body)['price'] as String);
      return MapEntry(s, price);
    }));
    _prices.addEntries(results);
    return Map.of(_prices);
  }

  void start() {
    if (isRunning || _controller.isClosed) return;
    if (live) {
      _startLive();
    } else {
      _timer = Timer.periodic(_interval, (_) => _tick());
    }
  }

  void _startLive() {
    final streams =
        _prices.keys.map((s) => '${s.toLowerCase()}usdt@miniTicker').join('/');
    _channel = WebSocketChannel.connect(
        Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams'));
    _wsSub = _channel!.stream.listen(
      (raw) {
        final data = jsonDecode(raw as String)['data'];
        final symbol = (data['s'] as String).replaceAll('USDT', '');
        final price = double.parse(data['c'] as String);
        final old = _prices[symbol] ?? price;
        _prices[symbol] = price;
        if (_controller.isClosed) return;
        _controller.add(PriceTick(
          symbol: symbol,
          price: price,
          previousPrice: old,
          time: DateTime.now(),
        ));
      },
      onError: (e) => debugPrint('WebSocket lỗi: $e'),
    );
  }

  void _tick() {
    for (final entry in _prices.entries.toList()) {
      final old = entry.value;
      // biến động ngẫu nhiên khoảng ±0.5%
      final next = old * (1 + (_random.nextDouble() - 0.5) * 0.01);
      _prices[entry.key] = next;

      _controller.add(PriceTick(
        symbol: entry.key,
        price: next,
        previousPrice: old,
        time: DateTime.now(),
      ));
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _wsSub?.cancel();
    _wsSub = null;
    _channel?.sink.close();
    _channel = null;
  }

  // Gọi khi thoát màn hình: dừng timer/websocket VÀ đóng controller
  Future<void> dispose() async {
    stop();
    await _controller.close();
    debugPrint('PriceService disposed');
  }
}