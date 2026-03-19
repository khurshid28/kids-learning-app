import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/database/database_helper.dart';
import 'package:learn_numbers_flutter/database/tables/colors_pic_table.dart';
import 'package:learn_numbers_flutter/ui/colorscreen/colorsPaintScreen.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({Key? key}) : super(key: key);

  @override
  _ColorScreenState createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  List<ColorsPicTable> colorsPicDataList = [];
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  int? _interstitialCount;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    _getColorsPicsData();
    _createBottomBannerAd();
    _createInterstitialAd();
    _getPreference();
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

  void _createInterstitialAd() {
    if (Debug.googleAd) {
      InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(nonPersonalizedAds: Utils.nonPersonalizedAds()),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            Preference.shared
                .setInt(Preference.interstitialCount, _interstitialCount! + 1);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _createInterstitialAd();
          },
        ),
      );
    }
  }

  void _showInterstitialAd(int index) {
    // if (_interstitialAd != null && _interstitialCount! % 5 == 0) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _moveToNextScreen(index).then((value) {
            setState(() {
              _createInterstitialAd();
              _getPreference();
            });
          });
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _moveToNextScreen(index).then((value) {
            setState(() {
              _createInterstitialAd();
              _getPreference();
            });
          });
        },
      );
      _interstitialAd!.show();
    } else {
      _moveToNextScreen(index).then((value) {
        setState(() {
          _createInterstitialAd();
          _getPreference();
        });
      });

    }
  }

  _getPreference() {
    _interstitialCount =
        Preference.shared.getInt(Preference.interstitialCount) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/color/bg.webp",
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
                _widgetList(),
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ),
          )
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

  _widgetList() {
    return Expanded(
      child: Container(
        alignment: Alignment.centerLeft,
        child: ListView.builder(
          itemBuilder: (context, pos) {
            return _itemOfListNumber(pos);
          },
          itemCount: colorsPicDataList.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Future _moveToNextScreen(int pos) async{
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ColorsPaintScreen(
                  colorsPicDataList: colorsPicDataList,
                  selectedPos: pos,
                )));
  }

  _itemOfListNumber(int pos) {
    return InkWell(
      onTap: () {
        /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ColorsPaintScreen(
                  colorsPicDataList: colorsPicDataList,
                  selectedPos: pos,
                )));*/

        _showInterstitialAd(pos);
      },
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: CColor.black, width: 5),
            color: CColor.white,
          ),
          margin: EdgeInsets.symmetric(
              horizontal: Sizes.width_5, vertical: Sizes.height_5),
          height: double.infinity,
          width: Sizes.width_60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.width_5),
            child: Image.asset(
              colorsPicDataList[pos].imgName.toString(),
            ),
          )),
    );
  }

  _getColorsPicsData() async {
    colorsPicDataList = await DataBaseHelper().getAllColorsPic();
    Debug.printLog(
        "_getColorsPicsData==>> " + colorsPicDataList.length.toString());
    setState(() {});
  }
}
