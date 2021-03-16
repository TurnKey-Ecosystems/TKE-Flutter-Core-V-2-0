import 'dart:developer';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

class TFC_EmailController {
  //static const String regexEmailAddressValidatorString = r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  //static RegExp regexEmailAddressValidator = RegExp(regexEmailAddressValidatorString);

  static void tryToSendEmail(MailOptions mailOptions) {
    FlutterMailer.send(mailOptions).catchError((e) {
      log(e.toString());
      tryToShareFile(mailOptions);
    });
  }

  static void tryToShareFile(MailOptions mailOptions) {
    String subject;

    if (mailOptions.subject == null || mailOptions.subject.isEmpty) {
      subject = "share";
    } else {
      subject = mailOptions.subject;
    }

    FlutterShare.shareFile(
      title: subject,
      chooserTitle: subject,
      text: mailOptions.body,
      filePath: mailOptions.attachments[0],
    ).catchError((e) {
      log(e.toString());
    });
  }
}