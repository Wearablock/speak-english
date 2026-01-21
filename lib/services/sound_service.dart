import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  static const String _recordStartSound = 'sounds/record_start.mp3';

  Future<void> playRecordStart() async {
    try {
      await _player.play(AssetSource(_recordStartSound));
    } catch (e) {
      // 효과음 파일이 없어도 앱 동작에 영향 없음
    }
  }

  void dispose() {
    _player.dispose();
  }
}
