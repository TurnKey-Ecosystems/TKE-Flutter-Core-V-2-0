import 'package:flutter/material.dart';
import '../../UI/FoundationalElements/TFC_AppBar.dart';
import '../../UI/FoundationalElements/TFC_BoxLimitations.dart';
import '../../Utilities/TFC_Event.dart';
import '../ConfigurationTypes/ChildToChildSpacing.dart';
import '../ConfigurationTypes/AxisSize.dart';
import '../ConfigurationTypes/ChildToBoxSpacing.dart';
import '../../Utilities/TFC_Utilities.dart';
import 'TFC_AppStyle.dart';
import '../PrebuiltWidgets/TFC_LoadingPage.dart';
import 'TFC_SelfReloadingWidget.dart';
import 'Box.dart';

abstract class TFC_Page extends TFC_SelfReloadingWidget {
  final IconData icon;
  final String loadingMessage;
  final bool Function() getShouldShowPage;
  final Box<TFC_MustBeFixedSize>? Function(BuildContext) appBarBuilder;

  double get internalPageWidth {
    return TFC_AppStyle.instance.screenWidth -
        (2 * TFC_AppStyle.instance.pageMargins);
  }

  TFC_Page({
    required this.icon,
    required this.loadingMessage,
    required this.getShouldShowPage,
    this.appBarBuilder = TFC_AppBar.blankAppBarBuilder,
    bool Function()? mayReload,
    List<TFC_Event?> reloadTriggers = const [],
    Key? key,
  })  : super(
          key: key,
          mayReload: mayReload,
          reloadTriggers: reloadTriggers,
        );

  Widget? getPageBody(BuildContext context);

  @override
  Widget buildWidget(BuildContext context) {
    return overrideableBuildWidget(context);
  }

  Widget overrideableBuildWidget(BuildContext context) {
    Widget body;

    debugPrint("Screen Height: ${TFC_AppStyle.instance.screenHeight}");
    
    // Grab the app bar now, because we'll use it multiple places later
    Box<TFC_MustBeFixedSize>? appBar = appBarBuilder(context);
    double appBarHeight_fu = 0.0;
    if (appBar != null) {
      appBarHeight_fu = appBar.height.size_fu!;
    }

    // Grab the bottom nav bar now, because we'll use it multiple places later
    Box<TFC_MustBeFixedSize>? bottomNavBar = getBottomNavigationBar(context);
    double bottomNavBarHeight_fu = 0.0;
    if (bottomNavBar != null) {
      bottomNavBarHeight_fu = bottomNavBar.height.size_fu!;
    }

    // Calculate the floating action button
    Widget? floatingActionButtonBox = null;
    Widget? floatingActionButton = buildFloatingActionButton(context);
    if (floatingActionButton != null) {
      floatingActionButtonBox = Box(
        width: AxisSize.growToFillSpace(),
        height: AxisSize.growToFillSpace(),
        childToBoxSpacing: ChildToBoxSpacing.bottomRight(
          padding_tu: 8,
        ),
        children: [
          floatingActionButton,
        ],
      );
    }

    if (getShouldShowPage()) {
      // Compile the page parts
      body = Box(
        width: AxisSize.fu(TFC_AppStyle.instance.screenWidth),
        height: AxisSize.fu(TFC_AppStyle.instance.screenHeight),
        mainAxis: Axis3D.Z_AXIS,
        children: [
          Box(
            width: AxisSize.growToFillSpace(),
            height: AxisSize.growToFillSpace(),
            mainAxis: Axis3D.VERTICAL,
            childToBoxSpacing: ChildToBoxSpacing.topCenter(),
            childToChildSpacingVertical: ChildToChildSpacing.noPadding(),
            children: [
              // Add a spacer for the app bar
              Box(
                width: AxisSize.growToFillSpace(),
                height: AxisSize.fu(appBarHeight_fu),
              ),
              
              // Add the body area
              Box(
                debugName: "Page Body",
                mainAxis: Axis3D.Z_AXIS,
                width: AxisSize.growToFillSpace(),
                height: AxisSize.fu(TFC_AppStyle.instance.screenHeight - bottomNavBarHeight_fu - appBarHeight_fu),
                childToBoxSpacing: ChildToBoxSpacing.topCenter(),
                children: [
                  // Scollable Bod Box
                  Box(
                    width: AxisSize.growToFillSpace(),
                    height: AxisSize.scrollableShrinkToFitContents(),
                    childToBoxSpacing: ChildToBoxSpacing.topCenter(),
                    children: [
                      getPageBody(context)
                    ],
                  ),
                ],
              ),

              // Add a spacer for the bottom nav bar
              Box(
                width: AxisSize.growToFillSpace(),
                height: AxisSize.fu(bottomNavBarHeight_fu),
              ),
            ],
          ),

          Box(
            width: AxisSize.growToFillSpace(),
            height: AxisSize.growToFillSpace(),
            mainAxis: Axis3D.VERTICAL,
            childToBoxSpacing: ChildToBoxSpacing.topCenter(),
            childToChildSpacingVertical: ChildToChildSpacing.noPadding(),
            children: [
              // Add the app bar
              appBar,
              
              // Add the floating action button and body spacer
              Box(
                mainAxis: Axis3D.Z_AXIS,
                width: AxisSize.growToFillSpace(),
                height: AxisSize.fu(TFC_AppStyle.instance.screenHeight - bottomNavBarHeight_fu - appBarHeight_fu),
                children: [
                  floatingActionButtonBox,
                ],
              ),

              // Add the bottom nav bar
              bottomNavBar,
            ],
          ),
        ],
      );
    } else {
      body = TFC_LoadingPage.icon(icon, loadingMessage);
      TFC_Utilities.when(getShouldShowPage).then((value) {
        reload();
      });
    }

    return Scaffold(
      //appBar: _appBarBuilder(context),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 0,
          maxWidth: TFC_AppStyle.instance.screenWidth,
          minHeight: 0,
          maxHeight: TFC_AppStyle.instance.screenHeight,
        ),
        child: body
      ),
      //floatingActionButton: floatingActionButton.value,
    );
  }

  void open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => this,
      ),
    );
  }

  static void openPage(TFC_Page page, BuildContext context) {
    page.open(context);
  }

  Box<TFC_MustBeFixedSize>? getBottomNavigationBar(BuildContext context) {
    return null;
  }

  Widget? buildFloatingActionButton(BuildContext context) {
    return null;
  }
}
