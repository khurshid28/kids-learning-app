import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/database/database_helper.dart';
import 'package:learn_numbers_flutter/database/tables/count_numbers_table.dart';
import 'package:learn_numbers_flutter/database/tables/learn_numbers_table.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
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
  bool _isLettersMode = false;

  // Pastel background colors that cycle per letter
  static const List<List<Color>> _letterBgGradients = [
    [Color(0xFFFFCDD2), Color(0xFFFFEBEE)], // red-pink
    [Color(0xFFFFCCBC), Color(0xFFFBE9E7)], // deep orange
    [Color(0xFFFFE0B2), Color(0xFFFFF3E0)], // orange
    [Color(0xFFFFF9C4), Color(0xFFFFFDE7)], // yellow
    [Color(0xFFC8E6C9), Color(0xFFE8F5E9)], // green
    [Color(0xFFB2EBF2), Color(0xFFE0F7FA)], // cyan
    [Color(0xFFBBDEFB), Color(0xFFE3F2FD)], // blue
    [Color(0xFFCE93D8), Color(0xFFF3E5F5)], // purple
    [Color(0xFFF8BBD0), Color(0xFFFCE4EC)], // pink
    [Color(0xFFB2DFDB), Color(0xFFE0F2F1)], // teal
  ];

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
                  _isLettersMode
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _letterBgGradients[
                                  currentPageValue % _letterBgGradients.length],
                            ),
                          ),
                        )
                      : Image.asset(
                          (listCountNumbersData.isNotEmpty)
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
    if (_isLettersMode) {
      final letter = LettersData.letters[itemIndex];
      final objectName = LettersData.letterObjectNames[letter] ?? '';
      final rest = objectName.length > 1 ? objectName.substring(1).toLowerCase() : '';
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: Sizes.width_6),
            child: Image.asset(
              listCountNumbersData[itemIndex].imgCountExample.toString(),
              height: Sizes.height_20,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: Sizes.width_4),
          Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontFamily: 'MochiyPop',
              fontWeight: FontWeight.w700,
              fontSize: FontSize.size_40,
              color: const Color(0xFF1565C0),
            ),
          ),
          Flexible(
            child: Text(
              rest,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'MochiyPop',
                fontWeight: FontWeight.w400,
                fontSize: FontSize.size_20,
                color: CColor.black,
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(left: Sizes.width_10),
          child: Image.asset(
            listCountNumbersData[itemIndex].imgCount.toString(),
            scale: 1.33,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Utils.textToSpeech(listCountNumbersData[itemIndex].imgName.toString(), flutterTts);
            },
            child: Image.asset(
              listCountNumbersData[itemIndex].imgCountExample.toString(),
              scale: 1.67,
            ),
          ),
        ),
      ],
    );
  }

  _getCountNumbersData() async {
    final isLetters = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    _isLettersMode = isLetters;
    if (isLetters) {
      final bgs = [
        'assets/images/count/imgCountBg/counting_bg1.webp',
        'assets/images/count/imgCountBg/counting_bg2.webp',
        'assets/images/count/imgCountBg/counting_bg3.webp',
        'assets/images/count/imgCountBg/counting_bg4.webp',
        'assets/images/count/imgCountBg/counting_bg5.webp',
      ];
      for (int i = 0; i < LettersData.letters.length; i++) {
        final l = LettersData.letters[i];
        listCountNumbersData.add(CountNumbersTable(
          id: i + 1,
          imgCount: LettersData.iconPath(l),
          imgCountExample: LettersData.letterObjects[l],
          imgCountBg: bgs[i % bgs.length],
          imgName: l.toUpperCase(),
        ));
        listLearnNumbersData.add(LearnNumbersTable(
          id: i + 1,
          categoryName: LettersData.iconPath(l),
          soundName: LettersData.soundPath(l),
        ));
      }
    } else {
      listLearnNumbersData = await DataBaseHelper().getAllLearnNumberData();
      listCountNumbersData = await DataBaseHelper().getAllCountNumberData();
    }
    Debug.printLog(
        "_getCountNumbersData==>> ${listCountNumbersData.length}");
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
