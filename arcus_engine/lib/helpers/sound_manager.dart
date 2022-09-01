import 'package:just_audio/just_audio.dart';

class AudioObject {
  AudioPlayer player;
  double volume;
  AudioObject({required this.player, required this.volume});
}

class SoundManager {
  static SoundManager shared = SoundManager._();
  SoundManager._();

  static SoundManager get instance => shared;
  Map<String, dynamic> audioCache = {};
  Map<String, AudioObject> playingTracks = {};

  void addItem(String key, String url) async {
    //var audioSource = AudioPlayer();
    //await audioSource.setAsset(url);
    //LockCachingAudioSource(url);
    audioCache[key] = url;
  }

  void playTrack(String key, {double volume = 0.5, bool loop = false}) async {
    AudioPlayer player = AudioPlayer();
    await player.setAsset(audioCache[key]);
    player.setVolume(volume);

    player.setLoopMode(loop == true ? LoopMode.all : LoopMode.off);

    player.playbackEventStream.listen((state) {
      //print(state);
      if (state.processingState == ProcessingState.completed) {
        player.dispose();
        playingTracks.remove(key);
      }
    });

    ///
    playingTracks[key] = AudioObject(player: player, volume: volume);
    await player.play();

    //player.play();
  }

  void pauseTrack(String key) {
    if (playingTracks[key] != null) {
      playingTracks[key]!.player.pause();
    }
  }

  void resumeTrack(String key) {
    if (playingTracks[key] != null) {
      playingTracks[key]!.player.play();
    }
  }

  void muteAll() {
    playingTracks.forEach((key, value) {
      value.player.setVolume(0.0);
    });
  }

  void unMuteAll() {
    playingTracks.forEach((key, value) {
      value.player.setVolume(value.volume);
    });
  }
}
