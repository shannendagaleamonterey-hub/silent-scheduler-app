import 'package:flutter/services.dart';

class DndService {
  static const MethodChannel _channel = MethodChannel('silent_scheduler/dnd');

  static Future<bool> isAccessGranted() async {
    final granted = await _channel.invokeMethod<bool>('isDndAccessGranted');
    return granted ?? false;
  }

  static Future<void> openSettings() async {
    await _channel.invokeMethod('openDndSettings');
  }

  static Future<void> enableSilentMode() async {
    await _channel.invokeMethod('enableSilentMode');
  }

  static Future<void> disableSilentMode() async {
    await _channel.invokeMethod('disableSilentMode');
  }

  static Future<void> scheduleModeChange({
    required DateTime startTime,
    required DateTime endTime,
    required String mode,
  }) async {
    await _channel.invokeMethod('scheduleModeChange', {
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'mode': mode,
    });
  }
}