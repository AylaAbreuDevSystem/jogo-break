import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;
  late AudioPlayer _musicPlayer;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 0.5;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
    _musicPlayer = AudioPlayer();
  }

  // Reproduzir efeitos sonoros
  Future<void> playSound(String soundFile) async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.setVolume(_soundVolume);
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      print('Erro ao reproduzir som: $e');
    }
  }

  // Reproduzir música de fundo
  Future<void> playMusic(String musicFile) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play(AssetSource('sounds/$musicFile'),
          isNotification: false);
    } catch (e) {
      print('Erro ao reproduzir música: $e');
    }
  }

  // Parar música
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // Parar todos os sons
  Future<void> stopAllSounds() async {
    await _audioPlayer.stop();
    await _musicPlayer.stop();
  }

  // Controlar volume de efeitos
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_soundVolume);
  }

  // Controlar volume de música
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  // Habilitar/desabilitar sons
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _audioPlayer.stop();
    }
  }

  // Habilitar/desabilitar música
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  // Limpar recursos
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
