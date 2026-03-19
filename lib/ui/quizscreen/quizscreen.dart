import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>  with TickerProviderStateMixin{

  List<int> rands = [];
  final _random = Random();
  var quizAnswer =0;
  FlutterTts flutterTts = FlutterTts();
  String strTap = "";
  AnimationController? shakeController1;
  Animation<double>? offsetAnimation1;

  AnimationController? shakeController2;
  Animation<double>? offsetAnimation2;

  AnimationController? shakeController3;
  Animation<double>? offsetAnimation3;

  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


  @override
  Widget build(BuildContext context) {

    offsetAnimation1 =
    Tween(begin: 0.0, end: (Platform.isIOS)?50.0:10.0).chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController1!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          shakeController1!.reverse();
        }
      });

    offsetAnimation2 =
    Tween(begin: 0.0, end: (Platform.isIOS)?50.0:10.0).chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController2!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          shakeController2!.reverse();
        }
      });

    offsetAnimation3 =
    Tween(begin: 0.0, end: (Platform.isIOS)?50.0:10.0).chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController3!)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          shakeController3!.reverse();
        }
      });
    return Scaffold(
      body: SafeArea(
        bottom: (Platform.isIOS)?false:true,
        top: false,
        right: false,
        left: false,
        child: Sizer(
          builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
            return Stack(
              children: [
                Image.asset("assets/images/quiz/quiz_bg.webp", fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Column(
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
                )
              ],
            );
          },
        ),
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
                Languages.of(context)!.txtTouch+" "+quizAnswer.toString(),
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
  void initState() {
    _createBottomBannerAd();
    shakeController1 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    shakeController2 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    shakeController3 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    generateQuiz();
    super.initState();
  }

  _widgetCenterView() {

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: offsetAnimation1!,
              builder: (buildContext, child) {
                return  InkWell(
                  onTap: () {
                    tapOnAnswer(0);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left:(Platform.isIOS)?offsetAnimation1!.value + 50.0:offsetAnimation1!.value +10.0,
                      right: (Platform.isIOS)?50.0 - offsetAnimation1!.value:10.0 -offsetAnimation1!.value ,
                    ),
                    child: Image.asset(
                      "assets/images/count/imgCount/count_"+rands[0].toString()+".webp",
                      scale: 2,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedBuilder(
              animation: offsetAnimation2!,
              builder: (buildContext, child) {
                return  InkWell(
                  onTap: () {
                    tapOnAnswer(1);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left:(Platform.isIOS)? offsetAnimation2!.value + 50.0:offsetAnimation2!.value +10.0,
                      right: (Platform.isIOS)?50.0 - offsetAnimation2!.value:10.0 -offsetAnimation2!.value ,
                    ),
                    child: Image.asset(
                      "assets/images/count/imgCount/count_"+rands[1].toString()+".webp",
                      scale: 2,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedBuilder(
              animation: offsetAnimation3!,
              builder: (buildContext, child) {
                return  InkWell(
                  onTap: () {
                    tapOnAnswer(2);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left:(Platform.isIOS)? offsetAnimation3!.value + 50.0:offsetAnimation3!.value +10.0,
                      right: (Platform.isIOS)?50.0 - offsetAnimation3!.value:10.0 -offsetAnimation3!.value ,
                    ),
                    child: Image.asset(
                      "assets/images/count/imgCount/count_"+rands[2].toString()+".webp",
                      scale: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  tapOnAnswer(int pos){
    Debug.printLog("pos on click ===>> "+(rands[pos] == quizAnswer).toString()
        +"  "+rands[pos].toString()+"  "+quizAnswer.toString());
    setStrTap(pos.toString());
    if(rands[pos] == quizAnswer){
      Utils.playSound("assets/sounds/quiz/right_answer.mp3");
      Future.delayed(const Duration(seconds: 1),(){
        generateQuiz();
      });
    }else{
      if(pos == 0) {
        shakeController1!.forward(from: 0.0);
      }else if(pos == 1) {
        shakeController2!.forward(from: 0.0);
      }else if(pos == 2) {
        shakeController3!.forward(from: 0.0);
      }
      Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
    }
  }

  generateQuiz(){
    rands.clear();
    for (int j = 0; j < 3; j++) {
      var randomNumber = RandomInt.generate(max: 20,min: 1);
      if(rands.isNotEmpty && !rands.contains(randomNumber)) {
        rands.add(randomNumber);
      }else{
        rands.add(RandomInt.generate(max: 20,min: 1));
      }
    }
    quizAnswer = rands[_random.nextInt(rands.length)];
    setState(() {

    });
    Debug.printLog("New Quiz==>> "+quizAnswer.toString());
  }

  setStrTap(String value){
    setState(() {
      strTap = "";
      strTap = value;
    });
  }
}

extension RandomInt on int {
  static int generate({int min = 0, @required int? max}) {
    final _random = Random();
    return min + _random.nextInt(max! - min);
  }
}
