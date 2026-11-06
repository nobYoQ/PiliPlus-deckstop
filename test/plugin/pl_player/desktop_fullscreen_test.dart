import 'dart:io';

import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/utils/fullscreen.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storage;
  late PlPlayerController controller;

  setUpAll(() async {
    storage = await Directory.systemTemp.createTemp('piliplus-fullscreen-');
    Hive.init(storage.path);
    GStorage.setting = await Hive.openBox('setting');
    GStorage.video = await Hive.openBox('video');
    GStorage.localCache = await Hive.openBox('localCache');
    controller = PlPlayerController.getInstance();
  });

  tearDown(() async {
    await controller.triggerFullScreen(status: false);
    exitDesktopFullScreen();
  });

  tearDownAll(() async {
    await Hive.close();
    await storage.delete(recursive: true);
  });

  test('窗口内全屏不会被下一集的自动全屏请求切换为屏幕全屏', () async {
    await controller.toggleFullScreen(inAppFullScreen: true);
    expect(controller.isFullScreen.value, isTrue);
    expect(controller.isInAppFullScreen.value, isTrue);

    await controller.triggerFullScreen();
    expect(controller.isFullScreen.value, isTrue);
    expect(controller.isInAppFullScreen.value, isTrue);

    await controller.triggerFullScreen(status: false);
    expect(controller.isFullScreen.value, isFalse);
    expect(controller.isInAppFullScreen.value, isFalse);
  }, skip: Platform.isAndroid || Platform.isIOS);

  test('两种全屏可以直接切换，重复点击当前模式退出全屏', () async {
    await controller.toggleFullScreen(inAppFullScreen: true);
    await controller.toggleFullScreen();
    expect(controller.isFullScreen.value, isTrue);
    expect(controller.isInAppFullScreen.value, isFalse);

    await controller.toggleFullScreen(inAppFullScreen: true);
    expect(controller.isFullScreen.value, isTrue);
    expect(controller.isInAppFullScreen.value, isTrue);

    await controller.toggleFullScreen(inAppFullScreen: true);
    expect(controller.isFullScreen.value, isFalse);
    expect(controller.isInAppFullScreen.value, isFalse);
  }, skip: Platform.isAndroid || Platform.isIOS);
}
