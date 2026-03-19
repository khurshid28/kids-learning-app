import 'dart:io';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class PairScreen extends StatefulWidget {
  const PairScreen({Key? key}) : super(key: key);

  @override
  _PairScreenState createState() => _PairScreenState();
}

class _PairScreenState extends State<PairScreen> {
  List<int> pairsArrayInt = [];
  List<PairData> pairsArray = [];
  double? itemHeight;
  double? itemWidth;
  int lastTouch = 0;
  bool isLottieLoad = false;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;


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
    generatePairs();
    _createBottomBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        bottom: (Platform.isIOS) ? false : true,
        top: false,
        right: false,
        left: false,
        child: Sizer(
          builder: (BuildContext context, Orientation orientation,
              DeviceType deviceType) {
            return Stack(
              children: [
                Image.asset(
                  "assets/images/pair/pair_bg.webp",
                  fit: BoxFit.cover,
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
      child: (isLottieLoad)?Lottie.asset('assets/animations/lottie/congrats.json')
          :_buildGameBody()
    );
  }

  Widget _buildGameBody() {
    return GridView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,padding:EdgeInsets.symmetric(horizontal: Sizes.width_60,vertical: Sizes.height_0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: pairsArray.length ~/ 4,
        childAspectRatio: 16/15.5,
        mainAxisSpacing: Sizes.height_0_5,
        crossAxisSpacing: Sizes.width_0_5
      ),
      itemBuilder: (context, index) {
        return _itemView(index);
      },
      itemCount: pairsArray.length ,
    );
  }

  _itemView(int index) {
    return InkWell(
      onTap: () {
        if(pairsArray[index].isSelect){
          return;
        }
        if(lastTouch != pairsArray[index].count! && lastTouch != 0) {
          Utils.playSoundTouchNumber("assets/sounds/touch.mp3").then((value) =>
              Utils.playSoundTouchNumber
                ("assets/sounds/learn/n_" + lastTouch.toString() +
                  ".mp3")
          );
        }else if(lastTouch == pairsArray[index].count! &&  lastTouch != 0){
          setState(() {
            pairsArray[index].isSelect = true;
          });

          Utils.playSoundTouchNumber("assets/sounds/quiz/right_answer.mp3");
          lastTouch = 0;

          var isSelectedItemList = pairsArray.where((element) => element.isSelect == false).toList();
          if(isSelectedItemList.isEmpty){
            setState(() {
              isLottieLoad= true;
            });
            Debug.printLog("Regenerate pairs===>>> "+isSelectedItemList.length.toString());
            Future.delayed(const Duration(seconds: 3),(){
              isLottieLoad= false;
              generatePairs();
            });
          }
        }
        else{
          Utils.playSound("assets/sounds/learn/n_" + pairsArray[index].count!.toString() +
              ".mp3");
          lastTouch = pairsArray[index].count!;
          setState(() {
            pairsArray[index].isSelect = true;
          });
        }
      },
      child: Opacity(
        opacity: (pairsArray[index].isSelect == false)?1:0,
        child: Image.asset(
          "assets/icons/learn/numbers/b"+pairsArray[index].count.toString()+".webp",
          width: Sizes.height_8,
          height: Sizes.height_8,
        ),
      ),
    );
  }

  generatePairs() {
    pairsArray.clear();
    pairsArrayInt.clear();
    var firstArray = List.generate(Constant.totalPairs, (index) => index + 1)
      ..shuffle();
    var secondArray = List.generate(Constant.totalPairs, (index) => index + 1)
      ..shuffle();

    pairsArrayInt.addAll(firstArray);
    pairsArrayInt.addAll(secondArray);

    for(int i=0;i<pairsArrayInt.length;i++){
      pairsArray.add(PairData(pairsArrayInt[i], false));
    }
    Debug.printLog("generatePairs==>>> " + pairsArray.toString());
    setState(() {});
  }
}

class PairData{
  int? count;
  bool isSelect = false;

  PairData(this.count,this.isSelect);
}