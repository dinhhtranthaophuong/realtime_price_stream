# Realtime Price Stream

Ứng dụng Flutter mô phỏng bảng giá crypto thời gian thực, minh họa lập trình bất đồng bộ với Future & Stream trong Dart.

## Tính năng
- Phát giá BTC, ETH, SOL, BNB mỗi 500ms bằng `StreamController.broadcast()`
- Toán tử Stream: `map`, `where`, `transform` (trung bình trượt), debounce tự viết
- `Future` + `async/await` để tải dữ liệu ban đầu
- `StreamBuilder` / `FutureBuilder` cập nhật giao diện
- Hủy luồng an toàn (cancel subscription, cancel Timer, close controller) khi thoát màn hình
- Màn hình demo Event Loop và Microtask Queue

## Cấu trúc
```
lib/
├── data/price_tick.dart          # Model dữ liệu
├── services/price_service.dart   # Nguồn phát Stream
├── services/stream_operators.dart# debounce, movingAverage
├── screens/price_screen.dart     # Bảng giá realtime
├── screens/event_loop_screen.dart# Demo Event Loop
└── main.dart
```

## Yêu cầu
- Flutter SDK (kiểm tra bằng `flutter doctor`)
- Android emulator hoặc điện thoại thật (bật USB debugging)

## Cài đặt và chạy
```bash
git clone [https://github.com/dinhhtranthaophuong/realtime_price_stream.git](https://github.com/dinhhtranthaophuong/realtime_price_stream.git)
cd realtime_price_stream
flutter pub get
flutter run
```

## Cấu hình
Dự án dùng dữ liệu giả lập nên **không cần file `.env` hay `google-services.json`**.

## Luồng dữ liệu
Timer → `PriceService` (broadcast Stream) → `where/map/transform` → `StreamBuilder` → UI

## Tác giả
Đinh Trần Thảo Phương - dinhhpyhere