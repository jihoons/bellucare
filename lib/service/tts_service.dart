import 'dart:ui';

import 'package:bellucare/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

import 'package:flutter_tts/flutter_tts.dart';

class TTSState {

}

class TTSServiceNotifier extends AsyncNotifier<TTSState> {
  late FlutterTts _flutterTts;

  final String _samsungTTSEngine = "com.samsung.SMT";
  final Map<String, String> _samsungVoiceMap = {
    "ko-KR-SMTg01": "지우",
    "ko-KR-SMTl04": "엘리",
    "ko-KR-SMTl05": "민정",
    "ko-KR-SMTl08": "룰루",

    "en-US-default": "ellis",
  };

  final String _googleTTSEngine = "com.google.android.tts";
  final Map<String, String> _googleVoiceMap = {
    "en-us-x-tpd-network": "smith",
    "ko-kr-x-kod-local": "지우",
  };

  Future<bool> hasSamsungTTS() async {
    var engines = await getEngines();
    return engines.where((engine) => engine.toString() == _samsungTTSEngine).isNotEmpty;
  }

  Future<List<dynamic>> getVoices() async {
    var voices = await _flutterTts.getVoices;
    var list = voices as List<dynamic>;
    List<String> prefixes = ["kor", "ko-"];
    return list.where(
          (v) {
        var voiceLocale = v["locale"] as String? ?? "";
        for (int i = 0; i < prefixes.length; i++) {
          if (voiceLocale.startsWith(prefixes[i])) {
            return true;
          }
        }
        return false;
      },
    ).toList();
  }

  Future<TTSVoices> getVoicesWithName(Map<String, String> nameMap, String defaultName) async {
    var voices = await getVoices();
    Map<String, VoiceInfo> map = {};
    for (var voice in voices) {
      var name = voice["name"];
      var mappedName = nameMap[name];
      if (mappedName != null) {
        map[mappedName] = VoiceInfo(mappedName, voice);
      }
    }
    if (map.isNotEmpty) {
      return TTSVoices(map, map[defaultName] ?? map.entries.first.value);
    }

    var voice = await _flutterTts.getDefaultVoice;
    map[defaultName] = VoiceInfo(defaultName, voice);
    return TTSVoices(map, map[defaultName] ?? map.entries.first.value);
  }

  Future<TTSVoices> getServiceVoices() async {
    if (await hasSamsungTTS()) {
      await setEngine(_samsungTTSEngine);
      return await getVoicesWithName(_samsungVoiceMap, "민정");
    } else {
      // google TTS 사용
      await setEngine(_googleTTSEngine);
      return getVoicesWithName(_googleVoiceMap, "지우");
    }
  }

  Future<List<dynamic>> getEngines() async {
    return await _flutterTts.getEngines as List<dynamic>;
  }

  Future<void> setEngine(String engine) async {
    _flutterTts.setEngine(engine);
  }

  Future<VoiceInfo> getSelectedVoice(String? voice) async {
    var voices = await getServiceVoices();
    if (voice != null && voice.isNotEmpty) {
      return voices.voiceMap[voice] ?? voices.defaultVoice;
    } else {
      return voices.defaultVoice;
    }
  }

  @override
  Future<TTSState> build() async {
    log('TTSService initialized');
    _flutterTts = FlutterTts();
    _flutterTts.setErrorHandler((msg) {
      debug("error: $msg");
    });
    await _flutterTts.awaitSpeakCompletion(true);
    var voiceInfo = await getSelectedVoice("민정");
    debug("voiceInfo $voiceInfo");
    await _flutterTts.setVoice(voiceInfo.voice.cast<String, String>());

    ref.onDispose(() {
      debug("dispose called stt");
      stop();
    },);

    return TTSState();
  }

  Future<void> speak(String text) async {
    log('Speaking: $text');
    _flutterTts.setVolume(0.5);
    _flutterTts.setPitch(0.5);
    _flutterTts.setSpeechRate(0.5);
    debug("${await _flutterTts.getDefaultVoice}");
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

final ttsServiceProvider = AsyncNotifierProvider<TTSServiceNotifier, TTSState>(() => TTSServiceNotifier());

class TTSVoices {
  const TTSVoices(this.voiceMap, this.defaultVoice);
  final Map<String, VoiceInfo> voiceMap;
  final VoiceInfo defaultVoice;

  @override
  String toString() {
    return 'TTSVoices{voiceMap: $voiceMap,\n defaultVoice: $defaultVoice}';
  }
}

class VoiceInfo {
  VoiceInfo(this.name, this.voice);
  final String name;
  final dynamic voice;

  @override
  String toString() {
    return 'VoiceInfo{name: $name, voice: $voice}';
  }
}
