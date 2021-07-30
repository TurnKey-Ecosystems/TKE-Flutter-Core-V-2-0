import 'package:flutter/material.dart';
import '../../UI/FoundationalElements/TFC_AppBar.dart';
import '../../UI/FoundationalElements/TFC_BoxLimitations.dart';
import '../../Utilities/TFC_Event.dart';
import '../ConfigurationTypes/TFC_ChildToChildSpacing.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_ChildToBoxSpacing.dart';
import '../../Utilities/TFC_BasicValueWrapper.dart';
import '../../Utilities/TFC_Utilities.dart';
import 'TFC_AppStyle.dart';
import '../PrebuiltWidgets/TFC_LoadingPage.dart';
import 'TFC_SelfReloadingWidget.dart';
import 'TFC_Box.dart';

abstract class TFC_Page extends TFC_SelfReloadingWidget {
  final IconData icon;
  final String loadingMessage;
  final bool Function() getShouldShowPage;
  final TFC_Box<TFC_MustBeFixedSize>? Function(BuildContext) appBarBuilder;
  final TFC_BasicValueWrapper<Widget> floatingActionButton =
      TFC_BasicValueWrapper(Container());
  final TFC_BasicValueWrapper<BuildContext?> _pageContext =
      TFC_BasicValueWrapper(null);
  BuildContext? get pageContext {
    return _pageContext.value;
  }

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
    _pageContext.value = context;
    return overrideableBuildWidget(context);
  }

  Widget overrideableBuildWidget(BuildContext context) {
    Widget body;

    debugPrint("Screen Height: ${TFC_AppStyle.instance.screenHeight}");
    
    // Grab the app bar now, because we'll use it multiple places later
    TFC_Box<TFC_MustBeFixedSize>? appBar = appBarBuilder(context);
    double appBarHeight_fu = 0.0;
    if (appBar != null) {
      appBarHeight_fu = appBar.height.size_fu!;
    }

    // Grab the bottom nav bar now, because we'll use it multiple places later
    TFC_Box<TFC_MustBeFixedSize>? bottomNavBar = getBottomNavigationBar(context);
    double bottomNavBarHeight_fu = 0.0;
    if (bottomNavBar != null) {
      bottomNavBarHeight_fu = bottomNavBar.height.size_fu!;
    }

    if (getShouldShowPage()) {
      // Compile the page parts
      body = TFC_Box(
        width: TFC_AxisSize.fu(TFC_AppStyle.instance.screenWidth),
        height: TFC_AxisSize.fu(TFC_AppStyle.instance.screenHeight),
        mainAxis: TFC_Axis.VERTICAL,
        childToBoxSpacing: TFC_ChildToBoxSpacing.topCenter(),
        childToChildSpacingVertical: TFC_ChildToChildSpacing.noPadding(),
        children: [
          // Add the app bar
          appBar,
          
          // Add the Body
          TFC_Box(
            debugName: "Page",
            mainAxis: TFC_Axis.VERTICAL,
            width: TFC_AxisSize.growToFillSpace(),
            height: TFC_AxisSize.fu(TFC_AppStyle.instance.screenHeight - bottomNavBarHeight_fu - appBarHeight_fu),
            children: [ getPageBody(context) ],
          ),

          // Add the bottom nav bar
          bottomNavBar,
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
      body: body,
      floatingActionButton: floatingActionButton.value,
    );
  }

  void setFloatingActionButton(Widget newFloatingActionButton) {
    floatingActionButton.value = newFloatingActionButton;
  }

  static void openPage(Widget page, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  TFC_Box<TFC_MustBeFixedSize>? getBottomNavigationBar(BuildContext context) {
    return null;
  }
}
