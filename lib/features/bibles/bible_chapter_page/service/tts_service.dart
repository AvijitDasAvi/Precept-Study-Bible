import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TtsService extends GetxService {
  FlutterTts? _tts;
  final _isPlaying = false.obs;
  final _playingIndex = (-1).obs;
  final _playQueue = Rxn<List<int>>();
  final _playQueuePos = (-1).obs;
  final _repeatSingle = false.obs;

  bool get isPlaying => _isPlaying.value;
  int get playingIndex => _playingIndex.value;
  List<int>? get playQueue => _playQueue.value;
  int get playQueuePos => _playQueuePos.value;
  bool get repeatSingle => _repeatSingle.value;

  @override
  void onInit() {
    super.onInit();
    _initializeTts();
  }

  void _initializeTts() {
    _tts = FlutterTts();
  }

  void setCompletionHandler(Function() handler) {
    _tts?.setCompletionHandler(handler);
  }

  Future<void> speak(String text) async {
    await _tts?.stop();
    await _tts?.speak(text);
  }

  Future<void> stop() async {
    await _tts?.stop();
    _isPlaying.value = false;
    _playingIndex.value = -1;
  }

  Future<void> pause() async {
    await _tts?.pause();
    _isPlaying.value = false;
  }

  void setPlaying(bool playing) {
    _isPlaying.value = playing;
  }

  void setPlayingIndex(int index) {
    _playingIndex.value = index;
  }

  void setPlayQueue(List<int>? queue) {
    _playQueue.value = queue;
  }

  void setPlayQueuePos(int pos) {
    _playQueuePos.value = pos;
  }

  void setRepeatSingle(bool repeat) {
    _repeatSingle.value = repeat;
  }

  void resetPlayback() {
    _isPlaying.value = false;
    _playingIndex.value = -1;
    _playQueue.value = null;
    _playQueuePos.value = -1;
  }

  @override
  void onClose() {
    try {
      _tts?.stop();
    } catch (_) {}
    _tts = null;
    super.onClose();
  }
}
