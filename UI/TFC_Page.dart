import 'dart:js';

import 'package:flutter/material.dart';
import '../Utilities/TFC_BasicValueWrapper.dart';
import 'TFC_PaddedColumn.dart';
import 'TFC_AppBarBuilder.dart';
import '../Utilities/TFC_Utilities.dart';
import 'TFC_AppStyle.dart';
import 'TFC_LoadingPage.dart';
import 'TFC_ReloadableWidget.dart';

abstract class TFC_Page extends TFC_ReloadableWidget {
  final IconData icon;
  final String loadingMessage;
  final bool Function() getShouldShowPage;
  final PreferredSizeWidget Function(BuildContext) _appBarBuilder;
  final double pageMargins;
  final double childPadding;
  final double preferredChildHeight;
  final TFC_TextType preferredChildTextType;
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
    double pageMargins = -1,
    double childPadding = -1,
    double preferredChildHeight = -1,
    this.preferredChildTextType = TFC_TextType.BODY,
    bool Function()? mayReload,
    Key? key,
  })  : _appBarBuilder = appBarBuilder,
        this.pageMargins = (pageMargins != -1)
            ? pageMargins
            : TFC_AppStyle.instance.pageMargins,
        this.childPadding = (childPadding != -1)
            ? childPadding
            : TFC_AppStyle.instance.pageMargins / 2.0,
        this.preferredChildHeight = (preferredChildHeight != -1)
            ? preferredChildHeight
            : 2.5 * TFC_AppStyle.instance.lineHeight,
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

      body = ListView(
        children: [
          Container(
            padding: EdgeInsets.all(pageMargins),
            child: TFC_PaddedColumn(
              padding: childPadding,
              children: children,
            ),
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
