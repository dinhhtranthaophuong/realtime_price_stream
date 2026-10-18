class PriceTick {
  final String symbol;
  final double price;
  final double previousPrice;
  final DateTime time;

  const PriceTick({
    required this.symbol,
    required this.price,
    required this.previousPrice,
    required this.time,
  });

  // Tính mức chênh lệch giá tuyệt đối
  double get change => price - previousPrice;

  // Tính phần trăm tăng/giảm so với giá trước đó
  double get changePercent =>
      previousPrice == 0 ? 0 : change / previousPrice * 100;

  // Kiểm tra giá tăng hay giảm (để đổi màu xanh/đỏ trên UI)
  bool get isUp => change >= 0;
}