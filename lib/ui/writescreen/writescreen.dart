import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class WriteScreen extends StatefulWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  TextEditingController? _editingController;
  bool _isLettersMode = false;

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  @override
  void initState() {
    _editingController = TextEditingController();
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    _createBottomBannerAd();
    super.initState();
  }



  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(
        nonPersonalizedAds: Utils.nonPersonalizedAds(),
      ),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    if (Debug.googleAd) {
      _bottomBannerAd.load();
    }
  }


  @override
  void dispose() {
    _editingController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/write/bg.webp",
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
              bottom: (Platform.isIOS) ? false : true,
              top: false,
              right: true,
              left: false,
              child: Column(
                children: [
                  _widgetTopView(),
                  _widgetCenterView(),
                  (_isBottomBannerAdLoaded)
                      ? SizedBox(
                    height: _bottomBannerAd.size.height.toDouble(),
                    width: _bottomBannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd),
                  )
                      : Container()
                ],
              ))
        ],
      ),
    );
  }

  _widgetTopView() {
    return Container(
      margin: EdgeInsets.only(
          top: Sizes.height_1_5,
          left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3,
          right: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              "assets/icons/learn/ic_home.webp",
              scale: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _editTextField() {
    return Container(
      height: Sizes.height_100,
      margin: EdgeInsets.symmetric(horizontal: Sizes.width_2),
      child: TextField(
        autofocus: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: _editingController,
        style: const TextStyle(
          color: CColor.white,
          fontSize: 40,
          fontFamily: "Digital",
          fontWeight: FontWeight.w400,
        ),
        cursorColor: CColor.black,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  _setTextOnBoard(String value) {
    if (_isLettersMode) {
      if (value.isNotEmpty && value != ' ') {
        Utils.playSound(LettersData.soundPath(value.toLowerCase()));
      }
    } else {
      if (value != Constant.strDas) {
        Utils.playSound("assets/sounds/learn/n_" + value + ".mp3");
      }
    }
    _editingController!.text = _editingController!.text + value;
  }

  Widget _letterKey(String letter) {
    return InkWell(
      onTap: () => _setTextOnBoard(letter),
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 42,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'MochiyPop',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _letterKeyboard() {
    final rows = [
      ['Q','W','E','R','T','Y','U','I','O','P'],
      ['A','S','D','F','G','H','J','K','L'],
      ['Z','X','C','V','B','N','M'],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...rows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: row.map((l) => _letterKey(l)).toList(),
                ),
              )),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _setTextOnBoard(' '),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        width: 140,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
                        ),
                        child: const Center(
                          child: Text('SPACE',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'MochiyPop'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_editingController!.text.isNotEmpty) {
                          _editingController!.text = _editingController!.text
                              .substring(0, _editingController!.text.length - 1);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        width: 80,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
                        ),
                        child: const Center(child: Icon(Icons.backspace_rounded, color: Colors.white, size: 22)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _widgetCenterView() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: Sizes.width_5,
                  right: Sizes.width_5,
                  top: Sizes.height_1,
                  bottom: Sizes.height_2),
              decoration: const BoxDecoration(
                  color: CColor.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: _editTextField(),
            ),
          ),
          if (_isLettersMode)
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(top: Sizes.height_1, bottom: Sizes.height_2, right: Sizes.width_2),
                child: _letterKeyboard(),
              ),
            )
          else
          Container(
            margin:
                EdgeInsets.only(top: Sizes.height_1, bottom: Sizes.height_2),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str1);
                        },
                        child: Image.asset(
                          "assets/icons/write/n1.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str2);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n2.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str3);
                        },
                        child: Image.asset(
                          "assets/icons/write/n3.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str4);
                        },
                        child: Image.asset(
                          "assets/icons/write/n4.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str5);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n5.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str6);
                        },
                        child: Image.asset(
                          "assets/icons/write/n6.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str7);
                        },
                        child: Image.asset(
                          "assets/icons/write/n7.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str8);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n8.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str9);
                        },
                        child: Image.asset(
                          "assets/icons/write/n9.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.strDas);
                        },
                        child: Image.asset(
                          "assets/icons/write/n_das.webp",
                          scale: 1.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _setTextOnBoard(Constant.str10);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: Sizes.width_3),
                          child: Image.asset(
                            "assets/icons/write/n10.webp",
                            scale: 1.5,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (_editingController!.text.isNotEmpty) {
                            var str = _editingController!.text
                                .toString()
                                .substring(
                                    0,
                                    _editingController!.text.toString().length -
                                        1);
                            _editingController!.text = str;
                          }
                        },
                        child: Image.asset(
                          "assets/icons/write/nb.webp",
                          scale: 1.5,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
