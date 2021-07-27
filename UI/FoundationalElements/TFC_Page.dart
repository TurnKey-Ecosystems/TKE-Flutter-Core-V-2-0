import 'package:flutter/material.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/ConfigurationTypes/TFC_BackgroundDecoration.dart';
import 'package:tke_dev_time_tracker_flutter_tryw/TKE-Flutter-Core/UI/ConfigurationTypes/TFC_BoxDecoration.dart';
import '../ConfigurationTypes/TFC_InterChildAlign.dart';
import '../ConfigurationTypes/TFC_AxisSize.dart';
import '../ConfigurationTypes/TFC_BoxToChildAlign.dart';
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
    this.paddingBetweenBoxAndContents_tu = 0,
    this.paddingInbetweenChildren_tu = 0,
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
      List<Widget> children = getPageContents(context);

      body = SingleChildScrollView(
        child: TFC_Box(
          mainAxis: TFC_Axis.VERTICAL,
          width: TFC_AxisSize.static_number_fu(TFC_AppStyle.instance.screenWidth),
          height: TFC_AxisSize.shrinkToFitContents(),
          This is not centering
          boxToChildAlign:
            TFC_BoxToChildAlign.topCenter(
              paddingBetweenBoxAndContents_tu: paddingBetweenBoxAndContents_tu,
            ),
          interChildAlignmentVertical:
            TFC_InterChildAlign.uniformPaddingTU(paddingInbetweenChildren_tu),
          children: children,
          boxDecoration: TFC_BoxDecoration.noOutline(
            backgroundDecoration: TFC_BackgroundDecoration.color(Colors.red),
          ),
        ),
      );
    } else {
      body = TFC_LoadingPage.icon(icon, loadingMessage);
      TFC_Utilities.when(getShouldShowPage).then((value) {
        reload();
      });
    }

    return Scaffold(
      appBar: _appBarBuilder(context),
      body: body,
      floatingActionButton: floatingActionButton.value,
      bottomNavigationBar: getBottomNavigationBar(context),
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
