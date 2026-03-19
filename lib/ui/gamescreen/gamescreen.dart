import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<GameNumbersData> numbersList = [];
  bool isLottieLoad = false;

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  void initState() {
    _generateNumbers();
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
          Image.asset("assets/images/learn/main_bg_learn_game.webp", fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            bottom: (Platform.isIOS)?false:true,
            top: false,
            right: true,
            left: false,
            child: Column(
              children: [
                _widgetTopView(),
                _widgetGridView(),
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

  _widgetTopView(){
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
                Languages.of(context)!.txtClickInSeq,
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

  _widgetGridView(){
    return Expanded(
      child:
      (isLottieLoad)?Lottie.asset('assets/animations/lottie/congrats.json')
      :GridView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          // physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:5,
              childAspectRatio: 1),
          itemCount: numbersList.length,
          itemBuilder: (BuildContext context, int index) {
            return _itemSequenceNumber(index, context);
          }),
    );
  }

  _itemSequenceNumber(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if(numbersList[index].isShow && numbersList[index].isClickTime) {

            Utils.playSound("assets/sounds/game/blast.mp3");
            Utils.playSound("assets/sounds/learn/n_"+numbersList[index].count.toString()+".mp3");

            var clickCountNumber = numbersList[index].count;
            var nextCountIndex = numbersList.indexWhere((element) => element.count == (clickCountNumber!+1));
            if(nextCountIndex != -1) {
              numbersList[nextCountIndex].isClickTime = true;
            }

            Debug.printLog("_itemSequenceNumber===>>> " +
                numbersList[index].isShow.toString() +
                "  " +numbersList[index].count.toString()+"  "+
                index.toString() +"  "+clickCountNumber.toString()+"  "+nextCountIndex.toString());

            numbersList[index].isShow = false;
            if(numbersList.where((element) => element.isShow == true).isEmpty){
              setState(() {
                isLottieLoad= true;
                Utils.playSound("assets/sounds/quiz/right_answer.mp3");
              });
              Future.delayed(const Duration(seconds: 3),(){
                isLottieLoad= false;
                _generateNumbers();
              });

            }
          }else{
            Utils.playSound("assets/sounds/wrong.mp3");
          }
        });
      },
      child: Opacity(
        opacity: numbersList[index].isShow?1:0,
        child: Container(
          alignment: (index == 1 || index == 3 || index == 6 || index == 8)
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          margin: EdgeInsets.only(
              bottom: Sizes.height_2,
              top: Sizes.height_1,),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/icons/game/bubble_" + numbersList[index].count.toString() + ".webp",
                scale: 6,
              ),
              AutoSizeText(
                numbersList[index].count.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MochiyPop",
                  fontWeight: FontWeight.w400,
                  color: CColor.white,
                  fontSize: FontSize.size_25,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  _generateNumbers(){
    numbersList.clear();
    for (int j = 1; j <= 10; j++) {
      numbersList.add(GameNumbersData(j,true,(j == 1)?true:false));
    }
    numbersList.shuffle();
    Debug.printLog("_generateNumbers==>>> "+numbersList.length.toString());
    setState(() {});
  }
}


class GameNumbersData{
  int? count;
  bool isShow = true;
  bool isClickTime = false;

  GameNumbersData(this.count,this.isShow,this.isClickTime);

}