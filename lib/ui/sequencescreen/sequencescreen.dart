import 'dart:io';
import 'dart:math';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/ui/quizscreen/quizscreen.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class SequenceScreen extends StatefulWidget {
  const SequenceScreen({Key? key}) : super(key: key);

  @override
  _SequenceScreenState createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {

  List<SequenceNumberData> sequenceNumberList = [];
  List<SequenceNumberData> answerNumbersList = [];
  bool isLottieLoad = false;
  bool onTapRightAnswer = false;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;



  @override
  void initState() {
    _generateSequence();
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
      body: SafeArea(
        bottom: (Platform.isIOS) ? false : true,
        top: false,
        right: false,
        left: false,
        child: Stack(
          children: [
            Image.asset(
              "assets/images/sequence/sequence_bg.webp",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _widgetTopView(),
                if(isLottieLoad)...{
                  Expanded(
                    child:Lottie.asset('assets/animations/lottie/congrats.json'),
                  )
                }else...{
                  _sequenceNumberGridView(),
                  _answerNumbersGridView(),
                },
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }


  _sequenceNumberGridView() {
    return Container(
      margin: EdgeInsets.only(top: Sizes.height_2),
      child: GridView.builder(
          padding: const EdgeInsets.all(5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:sequenceNumberList.length,
              crossAxisSpacing: 70,
              mainAxisSpacing: 25,
              childAspectRatio: 3),
          itemCount: sequenceNumberList.length,
          itemBuilder: (BuildContext context, int index) {
            return _itemSequenceNumber(index, context);
          }),
    );
  }

  _answerNumbersGridView() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: GridView.builder(
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:answerNumbersList.length,
                childAspectRatio: 1.7),
            itemCount: answerNumbersList.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemAnswerNumbers(index, context);
            }),
      ),
    );
  }


  _widgetTopView() {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(
        top: Sizes.height_1_5,
        left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2,
      ),
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

  _generateSequence() {
    sequenceNumberList.clear();
    answerNumbersList.clear();

    Utils.playSound("assets/sounds/sequence/completepatt.mp3");
    var rng = Random();
    var generateRandomNumber = rng.nextInt(17);
    if(generateRandomNumber == 0){
      generateRandomNumber++;
    }
    // sequenceNumberList.add(SequenceNumberData(generateRandomNumber, false,false));
    Debug.printLog("_generateSequence Start==>>> "+generateRandomNumber.toString());
    for(int i = 0;i < 3;i++){
      generateRandomNumber++;
      sequenceNumberList.add(SequenceNumberData(generateRandomNumber, false,false));
      Debug.printLog("Random Numbers==>>>> "+ generateRandomNumber.toString());
    }
    var indexForChangeVal = RandomInt.generate(max: 2, min: 0);
    sequenceNumberList[indexForChangeVal].isMissing = true;
    for (var element in sequenceNumberList) {
      Debug.printLog("sequenceNumberList==>>> "+indexForChangeVal.toString()+" "+element.count.toString()+" "+element.isMissing.toString() );
    }
    var missingData = sequenceNumberList.where((element) => element.isMissing == true).toList();
    answerNumbersList.addAll(missingData);
    for (int j = 0; j < 3; j++) {
      var randomNumber = RandomInt.generate(max: 20,min: 1);
      var missingNumber = sequenceNumberList.where((element) => element.isMissing == true).toList();
      if(missingNumber[0].count == randomNumber){
        randomNumber++;
      }
      answerNumbersList.add(SequenceNumberData(randomNumber, false,false));
    }
    answerNumbersList.shuffle();
    for (var element in answerNumbersList) {
      Debug.printLog("answerList==>>> "+element.count.toString()+" "+element.isMissing.toString() );
    }

  }

  _itemSequenceNumber(int index, BuildContext context) {
    return Container(
      alignment: (index == 0)
          ? Alignment.centerRight
          : (index == 2)
          ? Alignment.centerLeft
          : Alignment.center,
      child: (sequenceNumberList[index].isMissing)?
          Image.asset("assets/icons/sequence/ic_question_mark.webp")
          :Image.asset("assets/images/count/imgCount/count_" +
          sequenceNumberList[index].count.toString() +
          ".webp"),
    );
  }

  _itemAnswerNumbers(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        var missingWidgetIndex = sequenceNumberList.indexWhere((element) => element.isMissing == true);

        if(answerNumbersList[index].isMissing == true && missingWidgetIndex != -1){
          Utils.playSound("assets/sounds/learn/n_"+answerNumbersList[index].count.toString()+".mp3");

          Debug.printLog("_itemAnswerNumbers==>> "+missingWidgetIndex.toString());
          answerNumbersList[index].onTapRightAnswer = true;
          sequenceNumberList[missingWidgetIndex].isMissing = false;

          Future.delayed(const Duration(seconds: 1),(){
            setState(() {
              isLottieLoad = true;
              Utils.playSound("assets/sounds/quiz/right_answer.mp3");

            });
          });

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              isLottieLoad = false;
              _generateSequence();
            });
          });
        }else{
          Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
        }
        setState(() {});
      },
      child: (!answerNumbersList[index].onTapRightAnswer)
          ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: Image.asset(
                    getBalloonsFromIndex(index),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Sizes.height_4),
                  child: Image.asset("assets/images/count/imgCount/count_" +
                      answerNumbersList[index].count.toString() +
                      ".webp"),
                ),
              ],
            )
          : Container(),
    );
  }

  String getBalloonsFromIndex(int index){
    var imgName = "";
    if(index == 0){
      imgName = "assets/images/sequence/bl1.webp";
    }else if(index == 1){
      imgName = "assets/images/sequence/bl2.webp";
    }else if(index == 2){
      imgName = "assets/images/sequence/bl3.webp";
    }else if(index == 3){
      imgName = "assets/images/sequence/bl4.webp";
    }
    return imgName;
  }
}

class SequenceNumberData{
  int? count;
  bool isMissing = false;
  bool onTapRightAnswer = false;

  SequenceNumberData(this.count,this.isMissing,this.onTapRightAnswer);
}
