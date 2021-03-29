import '../DataStructures/TFC_Item.dart';
import '../UI/TFC_AppStyle.dart';
import '../UI/TFC_CustomWidgets.dart';
import '../UI/TFC_DialogManager.dart';
import 'package:flutter/material.dart';

class TFC_HiddenDelete extends StatelessWidget {
  //final TFC_Item itemToDelete;
  final String deleteWarning;
  final void Function() deleteItem;
  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Delete'),
    const Choice(title: 'Cancel'),
  ];

  TFC_HiddenDelete({@required this.deleteItem, @required this.deleteWarning});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Choice>(
      padding: EdgeInsets.all(0.0 /*TFC_AppStyle.instance.pageMargins*/),
      icon: Icon(Icons.more_vert, color: TFC_AppStyle.COLOR_HINT),
      onSelected: (Choice choice) {
        if (choice.title == "Delete") {
          TFC_DialogManager.showYesNoDialog(
            context: context,
            description: deleteWarning,
            onNo: () {
              Navigator.of(context).pop();
            },
            onYes: () {
              Navigator.of(context).pop();
              //itemToDelete.delete();
              deleteItem();
            },
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return choices.map((Choice choice) {
          return PopupMenuItem<Choice>(
              value: choice,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: (choice.title == "Delete")
                        ? Icon(Icons.delete, color: TFC_AppStyle.COLOR_ERROR)
                        : Icon(Icons.close,
                            color: TFC_AppStyle.textColors[TFC_TextType.BODY]),
                  ),
                  Container(
                    child: TFC_Text.body(
                      " " + choice.title,
                      color: (choice.title == "Delete")
                          ? TFC_AppStyle.COLOR_ERROR
                          : TFC_AppStyle.textColors[TFC_TextType.BODY],
                    ),
                  ),
                ],
              ));
        }).toList();
      },
    );
  }
}

class Choice {
  const Choice({this.title});

  final String title;
}
