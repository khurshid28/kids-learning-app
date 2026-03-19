import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/database/database_helper.dart';
import 'package:learn_numbers_flutter/database/tables/count_numbers_table.dart';
import 'package:learn_numbers_flutter/database/tables/learn_numbers_table.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CountScreen extends StatefulWidget {
  const CountScreen({Key? key}) : super(key: key);

  @override
  _CountScreenState createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  List<CountNumbersTable> listCountNumbersData = [];
  PageController pageController =
      PageController(initialPage: 0, keepPage: true);
  PageController pageControllerBottom =
  PageController(initialPage: 0, keepPage: true,viewportFraction: 0.1);
  int currentPageValue = 0;
  List<LearnNumbersTable> listLearnNumbersData = [];
  bool isClickArrow = false;
  ScrollController bottomScrollController = ScrollController();

  FlutterTts flutterTts = FlutterTts();
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void initState() {
    _createBottomBannerAd();
    _getCountNumbersData();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: (Platform.isIOS)?false:true,
        top: false,
        right: false,
        left: false,
        child: Sizer(
          builder: (BuildContext context, Orientation orientation,
              DeviceType deviceType) {
            return Stack(
              children: [
                Image.asset(
                  (listCountNumbersData
                          .isNotEmpty)
                      ? listCountNumbersData[currentPageValue]
                          .imgCountBg
                          .toString()
                      : "assets/images/count/imgCountBg/counting_bg1.webp",
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Column(
                  children: [
                    _widgetTopView(),
                    _widgetCenterView(),
                    _widgetBottomView(),
                    (_isBottomBannerAdLoaded)
                        ? SizedBox(
                      height: _bottomBannerAd.size.height.toDouble(),
                      width: _bottomBannerAd.size.width.toDouble(),
                      child: AdWidget(ad: _bottomBannerAd),
                    )
                        : Container()
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  _widgetTopView() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(
          top: Sizes.height_1_5,
          left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2,
          right: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.asset(
          "assets/icons/learn/ic_home.webp",
          scale: 6,
        ),
      ),
    );
  }

  _widgetCenterView() {
    return Expanded(
      child: Row(
        children: [
          if(currentPageValue != 0)...{
            InkWell(
              onTap: () {
                pageController.previousPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.ease);
                isClickArrow = true;
              },
              child: Container(
                margin: EdgeInsets.only(
                    left: (Platform.isIOS) ? Sizes.width_10 : Sizes.width_4),
                child: Image.asset(
                  "assets/icons/count/ic_forward.webp",
                  scale: 6,
                ),
              ),
            ),
          },
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: (Platform.isIOS) ? Sizes.width_6 : Sizes.width_1,bottom: Sizes.height_5),
              child: PageView.builder(
                itemCount: listCountNumbersData.length,
                controller: pageController,
                padEnds: false,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    currentPageValue = value;
                      animationFadeInFadeOut(currentPageValue);
                      Utils.playSound(
                          listLearnNumbersData[currentPageValue].soundName
                              .toString().replaceAll("assets/", ""));
                    pageControllerBottom.jumpToPage(currentPageValue);
                  });
                },
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _itemCountsCategory(itemIndex);
                },
              ),
            ),
          ),
          if(currentPageValue != listCountNumbersData.length-1)...{
            InkWell(
              onTap: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.ease);
              },
              child: Container(
                margin: EdgeInsets.only(right: Sizes.width_4),
                child: Image.asset(
                  "assets/icons/count/ic_next.webp",
                  scale: 6,
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
  _widgetBottomView() {
    return Container(
      height: Sizes.height_10,
      margin: EdgeInsets.only(bottom: Sizes.height_2,left: Sizes.width_5),
      child:  PageView.builder(
        itemCount: listCountNumbersData.length,
        controller: pageControllerBottom,
        padEnds: false,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int itemIndex) {
          return _itemNumbers(itemIndex);
        },
      ),
    );
  }

  _itemCountsCategory(int itemIndex) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: Sizes.width_10),
          child: Image.asset(
            listCountNumbersData[itemIndex].imgCount.toString(),
            scale: 2,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Utils.textToSpeech(listCountNumbersData[itemIndex].imgName.toString(), flutterTts);
            },
            child: Image.asset(
              listCountNumbersData[itemIndex].imgCountExample.toString(),
              scale: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  _getCountNumbersData() async {
    listLearnNumbersData = await DataBaseHelper().getAllLearnNumberData();
    listCountNumbersData = await DataBaseHelper().getAllCountNumberData();
    Debug.printLog(
        "_getCountNumbersData==>> " + listCountNumbersData.length.toString());
    setState(() {});
  }

  _itemNumbers(int i) {
    return InkWell(
      onTap: () {
        setState(() {
          animationFadeInFadeOut(i);
          Utils.playSound(
              listLearnNumbersData[i].soundName.toString());
          pageController.jumpToPage(i);
        });
      },
      child: AnimatedOpacity(
        opacity: listLearnNumbersData[i].opacity,
        duration: const Duration(milliseconds: 500),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal:(Platform.isIOS)?Sizes.width_0 :Sizes.width_2),
          child: Image.asset(
            listLearnNumbersData[i].categoryName.toString(),
            scale: 2,
          ),
        ),
      ),
    );
  }

  void animationFadeInFadeOut(int index) {
    setState(() => listLearnNumbersData[index].opacity = 0);
    Future.delayed(
        const Duration(milliseconds: 500),
            () => setState(() {
          listLearnNumbersData[index].opacity = 1;
        }));
  }

}
