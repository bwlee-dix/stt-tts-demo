package com.example.stt_tts_demo

import android.content.Intent
import android.os.Bundle
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "speech_channel"
    private var tts: TextToSpeech? = null
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TTS 초기화
        tts = TextToSpeech(this, this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
        when (call.method) {
            "startListening" -> {
                try {
                    startListening()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "startSpeaking" -> {
                try {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        speakText(text)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            "setVoice" -> {
                val voiceName = call.argument<String>("voiceName")
                if (voiceName != null) {
                    setVoice(voiceName)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Voice name cannot be null", null)
                }
            }
            "getVoices" -> {
                try {
                    val availableVoices = tts?.voices?.map { it.name } ?: listOf()
                    result.success(availableVoices)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }


    }

    // STT 시작
    private fun startListening() {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
        }
        try {
            startActivityForResult(intent, 1)
        } catch (e: Exception) {
            channel.invokeMethod("onError", "Speech recognition not available")
        }
    }

    // STT 결과 처리
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == RESULT_OK) {
            val results = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            val recognizedText = results?.get(0) ?: ""
            channel.invokeMethod("onSpeechResult", recognizedText)
        }
    }

    // TTS 초기화
    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val result = tts?.setLanguage(Locale.getDefault())
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                channel.invokeMethod("onError", "Language not supported")
            } else {
                // 가용한 Voice 목록 로드
                val availableVoices = tts?.voices?.map { it.name } ?: listOf()
                channel.invokeMethod("onVoicesAvailable", availableVoices)
            }
        } else {
            channel.invokeMethod("onError", "TTS initialization failed")
        }
    }

    private fun setVoice(voiceName: String) {
        val selectedVoice = tts?.voices?.find { it.name == voiceName }
        if (selectedVoice != null) {
            tts?.voice = selectedVoice
        } else {
            channel.invokeMethod("onError", "Voice not found")
        }
    }

    // TTS 텍스트 출력
    private fun speakText(text: String) {
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}