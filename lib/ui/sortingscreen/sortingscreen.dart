import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SortingScreen extends StatefulWidget {
  const SortingScreen({Key? key}) : super(key: key);

  @override
  _SortingScreenState createState() => _SortingScreenState();
}

class _SortingScreenState extends State<SortingScreen> {

  bool _isLettersMode = false;
  List<DraggableNumbersData> draggableNumbers = [];
  var quizAnswer = 0;
  var selectedIndex = 0;

  bool? isDrag = false;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  Map<String, String> totalNumbers = {
    "1": "assets/icons/learn/numbers/b1.webp",
    "2": "assets/icons/learn/numbers/b2.webp",
    "3": "assets/icons/learn/numbers/b3.webp",
    "4": "assets/icons/learn/numbers/b4.webp",
    "5": "assets/icons/learn/numbers/b5.webp",
    "6": "assets/icons/learn/numbers/b6.webp",
    "7": "assets/icons/learn/numbers/b7.webp",
    "8": "assets/icons/learn/numbers/b8.webp",
    "9": "assets/icons/learn/numbers/b9.webp",
    "10": "assets/icons/learn/numbers/b10.webp",
    "11": "assets/icons/learn/numbers/b11.webp",
    "12": "assets/icons/learn/numbers/b12.webp",
    "13": "assets/icons/learn/numbers/b13.webp",
    "14": "assets/icons/learn/numbers/b14.webp",
    "15": "assets/icons/learn/numbers/b15.webp",
    "16": "assets/icons/learn/numbers/b16.webp",
    "17": "assets/icons/learn/numbers/b17.webp",
    "18": "assets/icons/learn/numbers/b18.webp",
    "19": "assets/icons/learn/numbers/b19.webp",
    "20": "assets/icons/learn/numbers/b20.webp",
  };


  List<String> option = [];
  // List<String> que = [];
  List<DraggableNumbersData> que = [];
  Set<String> count = {};

  bool? accept = false;
  String? current;

  @override
  void initState() {
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    if (_isLettersMode) {
      totalNumbers = LettersData.iconMap;
    }
    generateNumbers();
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
            "assets/images/sorting/bg.webp",
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
                _draggableGridView(),
                _dragTargetGridView(),

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
          top: _isLettersMode ? Sizes.height_0_5 : Sizes.height_1_5,
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
                _isLettersMode
                    ? 'Arrange the letters A to Z'
                    : Languages.of(context)!.txtArrangeTheNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MochiyPop",
                  fontWeight: FontWeight.w400,
                  color: CColor.white,
                  fontSize: FontSize.size_20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _draggableGridView() {
    return Container(
      margin: EdgeInsets.only(top: _isLettersMode ? 0 : Sizes.height_2),
      alignment: Alignment.center,
      child: GridView.builder(
          padding: EdgeInsets.all(_isLettersMode ? 2 : 5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: option.length,
            childAspectRatio: _isLettersMode ? 4.0 : 3,
          ),
          itemCount: option.length,
          itemBuilder: (BuildContext context, int index) {
            return _itemDraggable(index, context);
          }),
    );
  }

  _itemDraggable(int index, BuildContext context) {
    return Container(
      alignment: (index == 0)
          ? Alignment.centerRight
          : (index == 2)
          ? Alignment.centerLeft
          : Alignment.center,
      child: Draggable(
        maxSimultaneousDrags: accept! || isDrag! ? 0 : 1,
        onDragStarted: () {
          setState(() {
            isDrag = true;
            current = totalNumbers[option[index]];
            if (_isLettersMode) {
              Utils.playSound(LettersData.soundPath(option[index]));
            } else {
              Utils.playSound("assets/sounds/learn/n_${current.toString().split("assets/icons/learn/numbers/b")[1].replaceAll(".webp", "")}.mp3");
            }
            Debug.printLog("current: ${current!}");
          });
        },
        onDragEnd: (_) {
          setState(() {
            isDrag = false;
          });
        },
        data: option[index],
        feedback: count.contains(option[index])? Container(
          color: CColor.black,
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.33,
        ) :
        Image.asset(
          totalNumbers[option[index]].toString(),
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.2,
        )
        ,
        childWhenDragging: Container(
          color: CColor.transparent,
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.33,
        ),

        child: count.contains(option[index])
            ? Container(
          color: CColor.transparent,
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.33,
        )
            : Image.asset(
          totalNumbers[option[index]].toString(),
        ),
      ),
    );
  }


  _dragTargetGridView() {
    return Expanded(
      child: GridView.builder(
          padding: _isLettersMode ? EdgeInsets.zero : null,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          // physics: const NeverScrollableScrollPhysics(),
          physics: _isLettersMode ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: _isLettersMode ? 5 : 35,
              mainAxisSpacing: _isLettersMode ? 0 : 30,
              childAspectRatio: _isLettersMode ? 1.3 : 0.92),
          itemCount: que.length,
          itemBuilder: (BuildContext context, int index) {
            return _dragTargets(index, context);
          }),
    );
  }


  _dragTargets(int index, BuildContext context) {
    return DragTarget(
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        return Container(
          margin: EdgeInsets.only(bottom: _isLettersMode ? 0 : Sizes.height_5),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                "assets/images/sorting/sort_$index.webp",
                fit: BoxFit.contain,
                height: _isLettersMode ? Sizes.height_15 : Sizes.height_22,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: _isLettersMode ? Sizes.height_1 : Sizes.height_2,
                  left: Sizes.width_1_5,
                ),
                child:(que[index].isAnswered)? Image.asset(
                  que[index].imageName!,
                  fit: BoxFit.cover,
                  height: _isLettersMode ? Sizes.height_6 : Sizes.height_10,
                ):Image.asset(
                  "assets/icons/sorting/box.png",
                  fit: BoxFit.cover,
                  height: _isLettersMode ? Sizes.height_6 : Sizes.height_10,
                ),
              ),
            ],
          ),
        );
      },
            onWillAcceptWithDetails: (details) {
              if (totalNumbers[details.data] == que[index].imageName) {
                Debug.printLog("accept");
                return true;
              } else {
                Debug.printLog("reject");
                return false;
              }
            },
            onAcceptWithDetails: (details) async {
              setState(() {
                accept = true;
              });
              if (count.length < 3) {
                setState(() {
                  count.add(details.data.toString());
                  var indexOfRightAnswer = que.indexWhere((element) => element.imageName == que[index].imageName.toString());
                  que[indexOfRightAnswer].isAnswered = true;
                  Debug.printLog("que:==>>  ${que[index].imageName}");
                  Utils.playSound("assets/sounds/matching/intelligent.mp3");
                });

                await Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() {
                    accept = false;
                  });
                });
              }

              if(count.length == 3){

                await Future.delayed(const Duration(seconds:3), () {
                  setState(() {
                    generateNumbers();
                  });
                });
              }
            },

            onLeave: (data) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!isDrag!) {
                  Debug.printLog("onLeave==>>>> $data  $isDrag");
                  Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
                }
              });

              // Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
            },
    );
  }

  generateNumbers() {
    Utils.playSound("assets/sounds/sequence/completepatt.mp3");
    option.clear();
    que.clear();
    count.clear();

    option = totalNumbers.keys.toList().sample(3);
    Debug.printLog("New Matching Numbers==>> $option");
    for (var element in option) {
      final int sortKey = _isLettersMode
          ? LettersData.letters.indexOf(element) + 1
          : int.parse(element);
      que.add(DraggableNumbersData(sortKey, totalNumbers[element]!, false));
      Debug.printLog("Total Numbers Element==>>> $element");
    }
    int sortById(DraggableNumbersData a, DraggableNumbersData b) => a.countSort!.compareTo(b.countSort!);
    que.sort(sortById);
    setState(() {});
  }
}


class DraggableNumbersData {
  int? countSort;
  String? imageName;
  bool isAnswered = false;

  DraggableNumbersData(this.countSort, this.imageName,this.isAnswered);
}