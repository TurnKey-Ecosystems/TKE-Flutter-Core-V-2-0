/*import 'package:flutter/material.dart';
import '../Utilities/TFC_Utilities.dart';
import './TFC_Page.dart';
import 'TFC_AppStyle.dart';
import 'TFC_LoadingPage.dart';
import 'TFC_PaddedColumn.dart';

abstract class TFC_TabbedPage extends TFC_Page {
  final int initialTabIndex;
  TabController _tabController;

  TFC_TabbedPage({
    @required IconData icon,
    @required String loadingMessage,
    @required bool Function() getShouldShowPage,
    this.initialTabIndex = 0,
    double pageMargins = -1,
    double childPadding = -1,
    double preferredChildHeight = -1,
    TFC_TextType preferredChildTextType = TFC_TextType.BODY,
    bool Function() mayReload,
    Key key,
  }) : super(
            icon: icon,
            loadingMessage: loadingMessage,
            getShouldShowPage: getShouldShowPage,
            pageMargins: pageMargins,
            childPadding: childPadding,
            preferredChildHeight: preferredChildHeight,
            preferredChildTextType: preferredChildTextType,
            mayReload: mayReload,
            key: key);

  // We're going to by pass this. It's probably not kosher, but we're going to do it.
  @override
  List<Widget> getPageContents(BuildContext context) {
    return null;
  }

  // Children should provide this
  List<TFC_TabProperties> getTabContents(BuildContext context);

  @override
  Widget buildWidget(BuildContext context) {
    pageContext = context;
    Widget body;

    if (getShouldShowPage()) {
      List<TFC_TabProperties> allTabsProperties = getTabContents(context);
      List<Widget> allTabsContents = [];

      // Setup the tab controller
      if (_tabController == null ||
          allTabsProperties.length != _tabController.length) {
        _tabController = new TabController(
            length: allTabsProperties.length,
            initialIndex: initialTabIndex,
            vsync: getStateInstance(context));
      }

      // Generate each of the tabs
      for (TFC_TabProperties tab in allTabsProperties) {
        allTabsContents.add(ListView(
          children: [
            Container(
              padding: EdgeInsets.all(pageMargins),
              child: TFC_PaddedColumn(
                padding: childPadding,
                children: tab.contents,
              ),
            ),
          ],
        ));
      }

      body = TabBarView(
        controller: _tabController,
        children: allTabsContents,
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
      floatingActionButton: floatingActionButton,
    );
  }

  void animateToTab(int tabIndex) {
    if (_tabController != null && _tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }
}

class TFC_TabProperties {
  final IconData icon;
  final String name;
  final List<Widget> contents;

  TFC_TabProperties(
      {@required this.icon, @required this.name, @required this.contents});
}*/
