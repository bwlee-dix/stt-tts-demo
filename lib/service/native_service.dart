import 'package:flutter/services.dart';

class NativeService {
  static const _channel = MethodChannel('speech_channel');
  static bool _isInitialized = false;
  static Function(String)? _onSpeechResult;

  // 초기화 메서드 추가
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _channel.setMethodCallHandler(_handleMethod);
      _isInitialized = true;
    }
  }

  // 메서드 콜 핸들러
  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onSpeechResult":
        if (_onSpeechResult != null) {
          _onSpeechResult!(call.arguments as String);
        }
        break;
      case "onError":
        print("Error from platform: ${call.arguments}");
        break;
    }
  }

  // STT 시작
  static Future<void> startListening() async {
    try {
      await initialize(); // 초기화 보장
      await _channel.invokeMethod('startListening');
    } on PlatformException catch (e) {
      print("Error in startListening: ${e.message}");
    }
  }

  // TTS 시작
  static Future<void> startSpeaking(String text) async {
    try {
      await initialize(); // 초기화 보장
      await _channel.invokeMethod('startSpeaking', {'text': text});
    } on PlatformException catch (e) {
      print("TTS Error: ${e.message}");
    }
  }

  // STT 결과 리스너 설정
  static void setSpeechResultListener(Function(String) onSpeechResult) {
    _onSpeechResult = onSpeechResult;
    initialize(); // 리스너 설정 시 초기화
  }

  static Future<List<String>> getVoices() async {
    try {
      final voices = await _channel.invokeMethod<List<dynamic>>('getVoices');
      return voices?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      print("Error getting voices: ${e.message}");
      return [];
    }
  }

  static Future<void> setVoice(String voiceName) async {
    try {
      await _channel.invokeMethod('setVoice', {'voiceName': voiceName});
    } on PlatformException catch (e) {
      print("Error setting voice: ${e.message}");
    }
  }
}
