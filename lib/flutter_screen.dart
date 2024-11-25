import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class FlutterScreen extends StatefulWidget {
  const FlutterScreen({super.key});

  @override
  State<FlutterScreen> createState() => _FlutterScreenState();
}

class _FlutterScreenState extends State<FlutterScreen> {
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  String _speechResult = "STT 결과가 여기에 표시됩니다.";
  bool isListening = false;
  double selectedSpeechRate = 0.5;

  @override
  void initState() {
    super.initState();
    tts.setSpeechRate(selectedSpeechRate);
  }

  // STT 시작
  Future<void> _startListening() async {
    bool available = await speech.initialize(
      onStatus: (val) => print("STT 상태: $val"),
      onError: (val) => print("STT 에러: $val"),
    );
    if (available) {
      setState(() => isListening = true);
      speech.listen(onResult: (val) {
        setState(() {
          _speechResult = val.recognizedWords;
        });
      });
    } else {
      setState(() => isListening = false);
    }
  }

  // TTS 시작
  Future<void> _startSpeaking() async {
    if (_speechResult != "STT 결과가 여기에 표시됩니다.") {
      await tts.speak(_speechResult);
    } else {
      const noTextMessage = "음성 인식된 텍스트가 없습니다. 먼저 STT를 시작해주세요.";
      setState(() {
        _speechResult = noTextMessage;
      });
      await tts.speak(noTextMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Package STT & TTS"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "사용 방법:",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "1. 'STT 시작'을 눌러 음성을 텍스트로 변환\n2. 'TTS 시작'을 눌러 변환된 텍스트를 음성으로 재생",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startListening,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "STT 시작",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startSpeaking,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "TTS 시작",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "인식된 텍스트:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _speechResult,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "속도 설정:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: selectedSpeechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 10,
                    label: selectedSpeechRate.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        selectedSpeechRate = value;
                        tts.setSpeechRate(selectedSpeechRate);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
