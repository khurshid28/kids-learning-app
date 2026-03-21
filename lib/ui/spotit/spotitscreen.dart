import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/ui/quizscreen/quizscreen.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class SpotItScreen extends StatefulWidget {
  const SpotItScreen({Key? key}) : super(key: key);

  @override
  _SpotItScreenState createState() => _SpotItScreenState();
}

class _SpotItScreenState extends State<SpotItScreen> with TickerProviderStateMixin{
  bool _isLettersMode = false;
  List<NumbersData> answerNumbersList = [];
  int? questionNumber = 0;
  List<bool> totalRightAnswer = [];
  var indexOfEgg = 0;
  AnimationController? controller;
  double isShowList = 1.0;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void initState() {
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    _generateNumbers();
    _createBottomBannerAd();
    _generateRightWrongAnswerList();
    controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  /// Center image shown in the SpotIt widget.
  String _centerImage() {
    if (_isLettersMode) {
      return LettersData.iconPath(LettersData.letters[questionNumber! - 1]);
    }
    return 'assets/images/count/imgCount/count_$questionNumber.webp';
  }

  /// Sound for the answer at [count] (1-based).
  String _soundForCount(int count) {
    if (_isLettersMode) {
      return LettersData.soundPath(LettersData.letters[count - 1]);
    }
    return 'assets/sounds/learn/n_$count.mp3';
  }

  /// Icon image for answer option at [count] (1-based).
  String _iconForCount(int count) {
    if (_isLettersMode) {
      return LettersData.iconPath(LettersData.letters[count - 1]);
    }
    return 'assets/icons/learn/numbers/b$count.webp';
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
            "assets/images/spotit/bg.webp",
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
            ),
          )
        ],
      ),
    );
  }

  _widgetTopView() {
    return Container(
      height: Sizes.height_6,
      margin: EdgeInsets.only(
          top: Sizes.height_1_5,
          left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3,
          right: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_3,
          bottom: Sizes.height_2),
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
              margin: EdgeInsets.only(right: Sizes.width_20),
              alignment: Alignment.center,
              child: ListView.builder(
                itemBuilder: (context, i) => _itemStarFillUnFill(i),
                itemCount: 5,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _itemStarFillUnFill(int index) {
    return (totalRightAnswer[index])
        ? Image.asset(
            "assets/icons/spotit/starFill.png",
            scale: 2.5,
          )
        : Image.asset(
            "assets/icons/spotit/starUnFill.png",
            scale: 2.5,
          );
  }

  _widgetCenterView() {

    return Expanded(
        child: Row(
      children: [
        Expanded(
          child: Image.asset("assets/images/spotit/eg_"+(indexOfEgg+1).toString()+".png", scale: 1.2),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset("assets/images/spotit/number_bg.webp", scale: 5),
              Image.asset(_centerImage(), scale: 4),
            ],
          ),
        ),
        Expanded(
            child:
                Image.asset("assets/images/spotit/chicken.webp", scale: 1.2)),
      ],
    ));
  }

  _widgetBottomView() {
    return Opacity(
      opacity: isShowList,
      child: Container(
        alignment: Alignment.center,
        child: GridView.builder(
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: answerNumbersList.length,
              childAspectRatio: 1.9,
            ),
            itemCount: answerNumbersList.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemAnswerNumbers(index, context);
            }),
      ),
    );
  }

  _itemAnswerNumbers(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {

          Debug.printLog("answerNumbersList[index] =>> "+answerNumbersList[index].onTapRightAnswer.toString());
          if(answerNumbersList[index].onTapRightAnswer){
            for(int i = 0 ;i < totalRightAnswer.length; i++){
              if(!totalRightAnswer[i]){
                totalRightAnswer[i] = true;
                break;
              }
            }

            isShowList = 0.0;
            indexOfEgg = totalRightAnswer.where((element) => element == true).toList().length;
            if(indexOfEgg == -1){
              indexOfEgg = 0;
            }
            Utils.playSound(_soundForCount(answerNumbersList[index].count!));
            Future.delayed(const Duration(milliseconds: 500),(){
              Utils.playSound("assets/sounds/spotit/egg_crack.mp3");
            });

            var totalAnswer = totalRightAnswer.where((element) => element == true).toList().length;
            if(totalAnswer == 5){
              Future.delayed(const Duration(milliseconds: 500),(){
                Utils.playSound("assets/sounds/quiz/right_answer.mp3");
              });
            }
            Future.delayed(Duration(milliseconds: (totalAnswer == 5)?2000:1500),(){
              _generateNumbers();
            });

            Debug.printLog("indexOfEgg==>> "+indexOfEgg.toString());
          }
          else{
            Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
          }
          Debug.printLog("totalRightAnswer List ==>> "+jsonEncode(totalRightAnswer));
        });
      },
      child: Padding(
        padding: EdgeInsets.all(Sizes.height_2),
        child: Image.asset(_iconForCount(answerNumbersList[index].count!)),
      ),
    );
  }

  _generateNumbers() {
    isShowList = 1.0;
    answerNumbersList.clear();

    final int maxVal = _isLettersMode ? 26 : 20;
    var totalAnswer = totalRightAnswer.where((element) => element == true).toList().length;
    if(totalAnswer == 5){
      indexOfEgg = 0;
      totalRightAnswer.clear();
      _generateRightWrongAnswerList();
    }

    var listOfNumbers = Utils.getListOfRandomNumbers(maxVal, 4);
    for (int j = 0; j < 4; j++) {
      if(j == 1){
        answerNumbersList.add(NumbersData(listOfNumbers[j], true, 0));
        questionNumber = listOfNumbers[j];
      }else {
        answerNumbersList.add(NumbersData(listOfNumbers[j], false, 0));
      }
    }
    answerNumbersList.shuffle();
    setState(() {});
  }

  _generateRightWrongAnswerList(){
    totalRightAnswer.clear();
    for (int i = 0; i < 5; i++) {
      totalRightAnswer.add(false);
    }
  }
}

class NumbersData {
  int? count;
  bool onTapRightAnswer = false;
  int? countStar;

  NumbersData(this.count, this.onTapRightAnswer, this.countStar);
}
