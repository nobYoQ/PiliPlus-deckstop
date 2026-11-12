import 'package:PiliPlus/common/widgets/scaffold/mini_scaffold.dart';
import 'package:PiliPlus/pages/video/controller.dart';
import 'package:PiliPlus/pages/video/introduction/ugc/controller.dart';
import 'package:PiliPlus/pages/video/member/controller.dart';
import 'package:PiliPlus/pages/video/member/view.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class _Video extends Fake implements VideoDetailController {
  @override
  String get heroTag => 'member-panel-test';
  @override
  int get aid => 1;
  @override
  String get bvid => 'test';
}

class _Intro extends Fake implements UgcIntroController {}

class _LoadingMember extends HorizontalMemberPageController {
  _LoadingMember() : super(mid: 1, currAid: '1');
  @override
  Future<void> getUserInfo() async {}
  @override
  Future<void> queryData([bool isRefresh = true]) async {}
}

void main() {
  testWidgets('点击关闭可从加载中的 UP 主面板返回原视频标签', (tester) async {
    final video = _Video();
    final scaffold = GlobalKey<MiniScaffoldState>();
    var tabsOpened = 0;
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: MiniScaffold(
            key: scaffold,
            body: Column(
              children: [
                TextButton(
                  onPressed: () {
                    late final PersistentBottomSheetController sheet;
                    sheet = scaffold.currentState!.showBottomSheet(
                      (_) => HorizontalMemberPage(
                        mid: 1,
                        onClose: sheet.close,
                        videoDetailController: video,
                        ugcIntroController: _Intro(),
                      ),
                      constraints: const BoxConstraints(),
                    );
                  },
                  child: const Text('UP 主头像'),
                ),
                for (final tab in ['评论', '相关推荐'])
                  TextButton(onPressed: () => tabsOpened++, child: Text(tab)),
              ],
            ),
          ),
        ),
      ),
    );
    Get.put<HorizontalMemberPageController>(
      _LoadingMember(),
      tag: video.heroTag,
    );
    await tester.tap(find.text('UP 主头像'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('评论').hitTestable(), findsNothing);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(HorizontalMemberPage), findsNothing);
    await tester.tap(find.text('评论'));
    await tester.tap(find.text('相关推荐'));
    expect(tabsOpened, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  }, skip: !PlatformUtils.isDesktop);
}
