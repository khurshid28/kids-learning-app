import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get txtSedentary;
  String get txtTouch;
  String get txtYes;

  String get txtNo;

  String get txtAreYouSureYouWantToClear;
  String get txtAreYouSureYouWantToExit;
  String get txtSaveSuccess;
  String get txtClickInSeq;
  String get txtCountObj;
  String get txtArrangeTheNumber;
}
