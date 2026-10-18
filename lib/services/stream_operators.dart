import 'dart:async';

/// Debounce: chỉ phát giá trị CUỐI CÙNG sau khi luồng im lặng đủ [duration].
StreamTransformer<T, T> debounce<T>(Duration duration) {
  return StreamTransformer<T, T>.fromBind((source) {
    Timer? timer;
    StreamSubscription<T>? sub;
    late final StreamController<T> controller;

    controller = StreamController<T>(
      onListen: () {
        sub = source.listen(
          (data) {
            timer?.cancel(); // có dữ liệu mới -> hủy hẹn giờ cũ
            timer = Timer(duration, () => controller.add(data));
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel(); // dọn timer khi bên nghe hủy
        return sub?.cancel();
      },
    );
    return controller.stream;
  });
}

/// Trung bình trượt của [window] giá trị gần nhất.
StreamTransformer<double, double> movingAverage(int window) {
  return StreamTransformer<double, double>.fromBind((source) {
    final buffer = <double>[];
    return source.map((v) {
      buffer.add(v);
      if (buffer.length > window) buffer.removeAt(0);
      return buffer.reduce((a, b) => a + b) / buffer.length;
    });
  });
}