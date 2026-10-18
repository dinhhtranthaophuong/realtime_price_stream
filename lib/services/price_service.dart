import 'dart:async';
import 'dart:math';

import '../data/price_tick.dart';

class PriceService {
  PriceService({Duration interval = const Duration(milliseconds: 500)})
      : _interval = interval;

  final Duration _interval;
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

  Stream<PriceTick> get stream => _controller.stream;

  /// where: lọc theo mã
  Stream<PriceTick> watch(String symbol) =>
      stream.where((t) => t.symbol == symbol);

  /// map: chuyển PriceTick -> double
  Stream<double> priceOf(String symbol) => watch(symbol).map((t) => t.price);

  /// where: chỉ lấy các lần biến động mạnh
  Stream<PriceTick> bigMoves({double thresholdPercent = 0.3}) =>
      stream.where((t) => t.changePercent.abs() >= thresholdPercent);

  bool get isRunning => _timer?.isActive ?? false;

  void start() {
    if (isRunning || _controller.isClosed) return;
    _timer = Timer.periodic(_interval, (_) => _tick());
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
  }

  // Gọi khi thoát màn hình: dừng timer VÀ đóng controller
  Future<void> dispose() async {
    stop();
    await _controller.close();
  }
}