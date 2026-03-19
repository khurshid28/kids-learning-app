import 'package:flutter/material.dart';

class Debug {
  static const debug = true;
  static const googleAd = true;

  static printLog(String str) {
    if (debug) debugPrint(str);
  }


}