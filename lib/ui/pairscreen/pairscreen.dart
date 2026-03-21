import 'dart:io';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:lottie/lottie.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
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
  static const List<List<Color>> _letterBgGradients = [
    [Color(0xFFFFF9C4), Color(0xFFFFE082)],
    [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
    [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
    [Color(0xFFF9FBE7), Color(0xFFF0F4C3)],
    [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
    [Color(0xFFFBE9E7), Color(0xFFFFCCBC)],
  ];
  int _bgColorIndex = 0;
  bool _isLettersMode = false;
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
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    generatePairs();
    _createBottomBannerAd();
    super.initState();
  }

  /// Icon asset for a pair card (count is 1-based index).
  String _iconPath(int count) {
    if (_isLettersMode) {
      return LettersData.iconPath(LettersData.letters[count - 1]);
    }
    return 'assets/icons/learn/numbers/b$count.webp';
  }

  /// Sound asset for a pair card (count is 1-based index).
  String _soundPath(int count) {
    if (_isLettersMode) {
      return LettersData.soundPath(LettersData.letters[count - 1]);
    }
    return 'assets/sounds/learn/n_$count.mp3';
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
                _isLettersMode
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _letterBgGradients[
                                _bgColorIndex % _letterBgGradients.length],
                          ),
                        ),
                      )
                    : Image.asset(
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
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: Sizes.width_5, vertical: Sizes.height_1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
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
              Utils.playSoundTouchNumber(_soundPath(lastTouch))
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
          Utils.playSound(_soundPath(pairsArray[index].count!));
          lastTouch = pairsArray[index].count!;
          setState(() {
            pairsArray[index].isSelect = true;
          });
        }
      },
      child: Opacity(
        opacity: (pairsArray[index].isSelect == false)?1:0,
        child: Image.asset(
          _iconPath(pairsArray[index].count!),
          width: Sizes.height_7,
          height: Sizes.height_7,
        ),
      ),
    );
  }

  generatePairs() {
    pairsArray.clear();
    pairsArrayInt.clear();
    _bgColorIndex++;
    const int total = Constant.totalPairs; // 10 pairs for both modes
    List<int> firstArray;
    if (_isLettersMode) {
      final allIndices = List.generate(LettersData.letters.length, (i) => i + 1)..shuffle();
      firstArray = allIndices.sublist(0, total);
    } else {
      firstArray = List.generate(total, (index) => index + 1)..shuffle();
    }
    var secondArray = [...firstArray]..shuffle();

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