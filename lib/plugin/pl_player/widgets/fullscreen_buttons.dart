import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/widgets/common_btn.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class PlayerFullscreenButtons extends StatelessWidget {
  const PlayerFullscreenButtons({
    super.key,
    required this.controller,
    this.buttonWidth = 34,
  });

  final PlPlayerController controller;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) => Obx(() {
    final isFullscreen = controller.isFullScreen.value;
    final isWindowFullscreen = controller.isInAppFullScreen.value;
    final isScreenFullscreen = isFullscreen && !isWindowFullscreen;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (PlatformUtils.isDesktop)
          ComBtn(
            width: buttonWidth,
            height: 30,
            tooltip: isWindowFullscreen ? '退出窗口内全屏（Esc）' : '窗口内全屏（Shift+F）',
            icon: Icon(
              isWindowFullscreen ? Icons.close_fullscreen : Icons.fit_screen,
              size: 24,
              color: Colors.white,
            ),
            onTap: () => controller.toggleFullScreen(inAppFullScreen: true),
          ),
        ComBtn(
          width: buttonWidth,
          height: 30,
          tooltip: PlatformUtils.isDesktop
              ? (isScreenFullscreen ? '退出屏幕全屏（Esc）' : '屏幕全屏（F）')
              : (isFullscreen ? '退出全屏' : '全屏'),
          icon: Icon(
            isScreenFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            size: 24,
            color: Colors.white,
          ),
          onTap: controller.toggleFullScreen,
          onSecondaryTap: () =>
              controller.toggleFullScreen(inAppFullScreen: true),
        ),
      ],
    );
  });
}
