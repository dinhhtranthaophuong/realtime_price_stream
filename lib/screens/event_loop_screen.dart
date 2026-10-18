import 'dart:async';
import 'package:flutter/material.dart';

class EventLoopScreen extends StatefulWidget {
  const EventLoopScreen({super.key});

  @override
  State<EventLoopScreen> createState() => _EventLoopScreenState();
}

class _EventLoopScreenState extends State<EventLoopScreen> {
  final List<String> _logs = [];

  void _log(String msg) {
    debugPrint(msg);
    if (mounted) setState(() => _logs.add(msg));
  }

  void _runQueueDemo() {
    setState(_logs.clear);
    _log('1. [sync] bắt đầu');
    Future(() => _log('5. [event queue] Future(...)'));
    Timer(Duration.zero, () => _log('6. [event queue] Timer.zero'));
    Future.microtask(() => _log('3. [microtask] Future.microtask'));
    scheduleMicrotask(() => _log('4. [microtask] scheduleMicrotask'));
    _log('2. [sync] kết thúc');
  }

  Future<void> _asyncStep() async {
    _log('A. trước await');
    await Future.delayed(const Duration(milliseconds: 500));
    _log('C. sau await (quay lại từ event queue)');
  }

  void _runAsyncDemo() {
    setState(_logs.clear);
    _asyncStep();
    _log('B. gọi xong, KHÔNG chờ (luồng chính vẫn chạy tiếp)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Loop & Microtask')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _runQueueDemo,
                  child: const Text('Demo hàng đợi'),
                ),
                FilledButton(
                  onPressed: _runAsyncDemo,
                  child: const Text('Demo async/await'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final l in _logs) ListTile(dense: true, title: Text(l)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}