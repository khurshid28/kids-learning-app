import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
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

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;



  @override
  void initState() {
    _editingController = TextEditingController();
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
    if (value != Constant.strDas) {
      Utils.playSound("assets/sounds/learn/n_" + value + ".mp3");
    }
    _editingController!.text = _editingController!.text + "" + value;
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
