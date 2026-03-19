import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/ui/quizscreen/quizscreen.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {

  List<PracticeNumberData> answerNumbersList = [];
  int? originalAnswer = 0;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void initState() {
    _generatePractice();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/practice/bg.webp",
            fit: BoxFit.cover,
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
                _widgetCountObjet(),
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ),
          ),
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
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: Sizes.width_15),
              alignment: Alignment.center,
              child: AutoSizeText(
                Languages.of(context)!.txtCountObj,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MochiyPop",
                  fontWeight: FontWeight.w400,
                  color: CColor.black,
                  fontSize: FontSize.size_20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _widgetCountObjet() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              margin: EdgeInsets.only(
                right: Sizes.width_2,
                  left: Sizes.width_6,
                  bottom: Sizes.height_2_5,
                  top: Sizes.height_1),
              decoration: BoxDecoration(
                  border: Border.all(color: CColor.mainBorder, width: 10),
                  borderRadius: BorderRadius.circular(30),
                  color: CColor.mainBg),
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: Sizes.width_2, vertical: Sizes.height_1),
                decoration: BoxDecoration(
                    border: Border.all(color: CColor.innerBorder, width: 10),
                    borderRadius: BorderRadius.circular(25),
                    color: CColor.innerBg),
                child:(originalAnswer == 0)?Container(): Image.asset(
                  "assets/images/practice/obj"+originalAnswer.toString()+".png",
                  scale: 2.5,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(bottom: (Platform.isAndroid) ? Sizes.height_1 : 0,
                  right: (Platform.isAndroid) ? Sizes.width_2 : 0),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:1,
                      mainAxisSpacing: 5,
                      childAspectRatio: 2.5),
                  itemCount: answerNumbersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _itemAnswerNumbers(index, context);
                  }),
            ),
          )
        ],
      ),
    );
  }


  _itemAnswerNumbers(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if(answerNumbersList[index].onTapRightAnswer){
            Utils.playSound("assets/sounds/quiz/right_answer.mp3");
            _generatePractice();
          }else{
            Utils.playSound("assets/sounds/wrong.mp3");
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: CColor.black, width: 5),
            borderRadius: BorderRadius.circular(15),
            color: CColor.boxColorArray[index]),
        child:  AutoSizeText(
          answerNumbersList[index].count.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "MochiyPop",
            fontWeight: FontWeight.w400,
            color: CColor.black,
            fontSize: FontSize.size_20,
          ),
        ),
      ),
    );
  }

  _generatePractice() {
    originalAnswer = 0;
    answerNumbersList.clear();

    var rng = Random();
    var generateRandomNumber = rng.nextInt(20);
    originalAnswer = generateRandomNumber;
    answerNumbersList.add(PracticeNumberData(generateRandomNumber, true));

    for (int j = 0; j < 3; j++) {

      var randomNumber = RandomInt.generate(max: 20,min: 1);
      if(randomNumber == generateRandomNumber){
        answerNumbersList.add(PracticeNumberData(randomNumber+1,false));
      }else {
        answerNumbersList.add(PracticeNumberData(randomNumber, false));
      }
    }

    answerNumbersList.shuffle();
    setState(() {});
  }


}

class PracticeNumberData{
  int? count;
  bool onTapRightAnswer = false;

  PracticeNumberData(this.count,this.onTapRightAnswer);
}
