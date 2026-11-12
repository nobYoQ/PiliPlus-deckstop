import 'dart:io';

import 'package:PiliPlus/models/common/audio_normalization.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:media_kit/media_kit.dart';

class _VolumeControl with AudioNormalizationMixin {}

class _RecordingPlayer extends Fake implements Player {
  final filters = <String>[];
  double? volume;

  @override
  void setProperty(String property, String value) {
    expect(property, 'af');
    filters.add(value);
  }

  @override
  Future<void> setVolume(double volume, {bool synchronized = true}) async {
    this.volume = volume;
  }
}

void main() {
  test('桌面音量上限默认 500%，沿用用户保存的上限和播放音量', () async {
    final dir = await Directory.systemTemp.createTemp('piliplus-volume-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });
    GStorage.setting = await Hive.openBox('setting');
    expect(Pref.maxVolume, 5);
    expect(Pref.desktopVolume, 1);
    await GStorage.setting.put(SettingBoxKey.maxVolume, 2.0);
    expect(Pref.maxVolume, 2);
    await GStorage.setting.put(SettingBoxKey.maxVolume, 5.0);
    expect(Pref.maxVolume, 5);
    expect(Pref.desktopVolume, 1);
  });

  test('Windows 将选定音量交给 mpv，最高可达 500%', () async {
    final control = _VolumeControl();
    final player = _RecordingPlayer();
    for (final volume in [2.0, 5.0, 0.0, 0.5]) {
      await control.setVolumeCapped(player, volume);
      expect(player.volume, volume * 100);
    }
    expect(player.filters, isEmpty);
  }, skip: !Platform.isWindows);

  test('500% 的增益在限幅器范围内，重建播放器后仍生效', () async {
    final control = _VolumeControl();
    final first = _RecordingPlayer();
    final second = _RecordingPlayer();
    await control.setVolumeCapped(first, 5);
    await control.setVolumeCapped(first, 5);
    await control.setVolumeCapped(second, 5);
    final filter = first.filters.single;
    expect(second.filters, [filter]);
    expect(second.volume, 100);
    final match = RegExp(r'^alimiter=level_in=64:limit=([\d.]+):level=1$')
        .firstMatch(filter)!;
    expect(64 / double.parse(match[1]!), closeTo(125, 2));

    await control.setVolumeCapped(second, 2);
    expect(second.filters.last, startsWith('alimiter=level_in=7.943:'));
    await control.setVolumeCapped(second, 0.5);
    expect(second.filters.last, isEmpty);
    expect(second.volume, 50);
  }, skip: Platform.isWindows);
}
