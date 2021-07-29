import 'package:flutter/material.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_ChildToChildSpacing.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_ChildToBoxSpacing.dart';
import '../../Utilities/TFC_BasicValueWrapper.dart';
import '../PrebuiltWidgets/TFC_AppBarBuilder.dart';
import '../../Utilities/TFC_Utilities.dart';
import 'TFC_AppStyle.dart';
import '../PrebuiltWidgets/TFC_LoadingPage.dart';
import 'TFC_ReloadableWidget.dart';
import 'TFC_Box.dart';

abstract class TFC_Page extends TFC_ReloadableWidget {
  final IconData icon;
  final String loadingMessage;
  final bool Function() getShouldShowPage;
  final PreferredSizeWidget Function(BuildContext) _appBarBuilder;
  final double paddingBetweenBoxAndContents_tu;
  final double paddingInbetweenChildren_tu;
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
    PreferredSizeWidget Function(BuildContext) appBarBuilder =
        TFC_AppBarBuilder.buildDefaultAppBar,
    this.paddingBetweenBoxAndContents_tu = 7,
    this.paddingInbetweenChildren_tu = 7,
    bool Function()? mayReload,
    Key? key,
  })  : _appBarBuilder = appBarBuilder,
        super(key: key, mayReload: mayReload);

  List<Widget> getPageContents(BuildContext context);

  @override
  Widget buildWidget(BuildContext context) {
    _pageContext.value = context;
    return overrideableBuildWidget(context);
  }

  Widget overrideableBuildWidget(BuildContext context) {
    Widget body;

    if (getShouldShowPage()) {
      List<Widget> pageParts = [];
      pageParts.add(
        TFC_Box(
          debugName: "Page",
          mainAxis: TFC_Axis.VERTICAL,
          width: TFC_AxisSize.growToFillSpace(),
          height: TFC_AxisSize.scrollableShrinkToFitContents(),
          children: getPageContents(context),
          childToBoxSpacing:
            TFC_ChildToBoxSpacing.topCenter(
              padding_tu: paddingBetweenBoxAndContents_tu,
            ),
          childToChildSpacingVertical:
            TFC_ChildToChildSpacing.uniformPaddingTU(paddingInbetweenChildren_tu),
        )
      );

      // Create the bottom nav bar
      Widget? bottomNavBar = getBottomNavigationBar(context);
      if (bottomNavBar != null) {
        pageParts.add(bottomNavBar);
      }

      // Compile the page parts
      body = TFC_Box(
        width: TFC_AxisSize.fu(TFC_AppStyle.instance.screenWidth),
        height: TFC_AxisSize.fu(TFC_AppStyle.instance.screenHeight),
        childToBoxSpacing: TFC_ChildToBoxSpacing.topCenter(),
        childToChildSpacingVertical: TFC_ChildToChildSpacing.spaceBetween(),
        children: pageParts,
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

  Widget? getBottomNavigationBar(BuildContext context) {
    return null;
  }
}
