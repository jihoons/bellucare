import 'package:bellucare/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTState {
  STTState({
    required this.speechToText,
    required this.speechEnabled,
  });
  final bool speechEnabled;
  final SpeechToText speechToText;

  STTState copyWith({
    SpeechToText? speechToText,
    bool? speechEnabled
  }) {
    return STTState(
      speechToText: speechToText ?? this.speechToText,
      speechEnabled: speechEnabled ?? this.speechEnabled
    );
  }

  bool get isListening => (speechEnabled && speechToText.isListening);
  bool get canListen => (speechEnabled && speechToText.isNotListening);
}

class STTNotifier extends AsyncNotifier<STTState> {
  Future<void> reset() async {
    state = await AsyncValue.guard(() async {
      return state.value!.copyWith();
    },);
  }

  @override
  Future<STTState> build() async {
    var speechToText = SpeechToText();
    var speechEnabled = await speechToText.initialize(
      onStatus: (status) {
        debug("status changed: $status");
        reset();
      },
    );
    ref.onDispose(() {
      debug("dispose called stt");
      stopListening();
    },);
    return STTState(
      speechToText: speechToText,
      speechEnabled: speechEnabled
    );
  }

  final Duration defaultListeningFor = Duration(seconds: 3);
  Future<void> startListening(Function(String) callback, {
    Duration? listenFor,
  }) async {
    if (state.hasValue) {
      STTState value = state.value!;
      if (value.canListen) {
        debug("call listen");
        value.speechToText.listen(
          listenFor: listenFor ?? defaultListeningFor,
          listenOptions: SpeechListenOptions(

          ),
          onResult: (result) {
            debug("listening result: ${result.finalResult}");
            debug("listening words: ${result.recognizedWords}");
            debug("listening result: ${result.alternates}");
            if (result.finalResult) {
              callback.call(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (state.hasValue) {
      STTState value = state.value!;
      value.speechToText.stop();
    }
  }
}

final sttProvider = AsyncNotifierProvider<STTNotifier, STTState>(() {
  return STTNotifier();
});
