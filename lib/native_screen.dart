import 'package:flutter/material.dart';
import 'package:stt_tts_demo/service/native_service.dart';

class NativeScreen extends StatefulWidget {
  const NativeScreen({super.key});

  @override
  State<NativeScreen> createState() => _NativeScreenState();
}

class _NativeScreenState extends State<NativeScreen> {
  String _speechResult = "STT 결과가 여기에 표시됩니다.";
  List<String> _voices = []; // 가용한 음성 목록
  String? _selectedVoice; // 선택된 음성

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await NativeService.initialize();

    // STT 결과 리스너 설정
    NativeService.setSpeechResultListener((result) {
      setState(() {
        _speechResult = result;
      });
    });

    // 음성 목록 가져오기
    final voices = await NativeService.getVoices();
    if (mounted) {
      setState(() {
        _voices = voices;
        if (voices.isNotEmpty) {
          _selectedVoice = voices.first; // 기본으로 첫 번째 음성 선택
        }
      });

      // 기본 음성 설정
      if (voices.isNotEmpty) {
        await _setVoice(voices.first);
      }
    }
  }

  // TTS 시작 - STT 결과 텍스트를 사용
  Future<void> _startSpeaking() async {
    if (_speechResult != "STT 결과가 여기에 표시됩니다.") {
      await NativeService.startSpeaking(_speechResult);
    } else {
      const noTextMessage = "음성 인식된 텍스트가 없습니다. 먼저 STT를 시작해주세요.";
      setState(() {
        _speechResult = noTextMessage;
      });
      await NativeService.startSpeaking(noTextMessage);
    }
  }

  // STT 시작
  Future<void> _startListening() async {
    await NativeService.startListening();
  }

  // 음성 변경
  Future<void> _setVoice(String voiceName) async {
    await NativeService.setVoice(voiceName);
    if (mounted) {
      setState(() {
        _selectedVoice = voiceName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STT & TTS 예시"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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

            // 음성 선택 드롭다운
            if (_voices.isNotEmpty)
              DropdownButton<String>(
                value: _selectedVoice,
                onChanged: (value) {
                  if (value != null) _setVoice(value);
                },
                items: _voices.map((voice) {
                  return DropdownMenuItem(value: voice, child: Text(voice));
                }).toList(),
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
          ],
        ),
      ),
    );
  }
}
