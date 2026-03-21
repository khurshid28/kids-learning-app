import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/utils/ad_helper.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({Key? key}) : super(key: key);

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen>
    with TickerProviderStateMixin {
  bool _isLettersMode = false;
  bool? isDrag = false;
  String? current;

  List<DraggableImagesData> listDraggableData = [];
  Map<String, String> totalImages = {
    "apple": "assets/images/train/apple.webp",
    "ball": "assets/images/train/ball.webp",
    "balloon": "assets/images/train/balloon.webp",
    "banana": "assets/images/train/banana.webp",
    "butterfly": "assets/images/train/butterfly.webp",
    "car": "assets/images/train/car.webp",
    "clock": "assets/images/train/clock.webp",
    "duck": "assets/images/train/duck.webp",
    "egg": "assets/images/train/egg.webp",
    "fish": "assets/images/train/fish.webp",
    "flower": "assets/images/train/flower.webp",
    "muffin": "assets/images/train/muffin.webp",
    "orange": "assets/images/train/orange.webp",
    "pencil": "assets/images/train/pencil.webp",
    "pig": "assets/images/train/pig.webp",
    "pizza": "assets/images/train/pizza.webp",
  };

  List<String> option = [];

  List<String> que = [];
  Set<String> count = {};

  int? currentIndex = 0;
  bool? accept = false;
  bool isLottieLoad = false;

  double startPos = -1.0;
  double endPos = 0.0;
  Curve curve = Curves.elasticOut;
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  @override
  void initState() {
    _isLettersMode = Preference.shared.getBool(Preference.isLettersMode) ?? false;
    _createBottomBannerAd();
    generateImagesOptions();
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
          "assets/images/train/bg.webp",
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
                _slidingTrain(),
                (_isBottomBannerAdLoaded)
                    ? SizedBox(
                  height: _bottomBannerAd.size.height.toDouble(),
                  width: _bottomBannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bottomBannerAd),
                )
                    : Container()
              ],
            ))
      ],
    ));
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
        ],
      ),
    );
  }

  _draggableGridView() {
    return GridView.builder(
        padding: const EdgeInsets.all(5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 70,
            mainAxisSpacing: 25,
            childAspectRatio: 2),
        itemCount: listDraggableData.length,
        itemBuilder: (BuildContext context, int index) {
          return _draggable(index, context);
        });
  }

  _draggable(int index, BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Draggable(
        maxSimultaneousDrags: accept! || isDrag! ? 0 : 1,
        onDragCompleted: () {
          setState(() {
            Debug.printLog("onDragCompleted==>> ");
          });
        },
        onDragStarted: () {
          setState(() {
            currentIndex = index;
            isDrag = true;
            current = totalImages[option[index]];
            Utils.playSound("assets/sounds/train/" +
                current
                    .toString()
                    .split("assets/images/train/")[1]
                    .replaceAll(".webp", "") +
                ".mp3");
            Debug.printLog("current: " + current!);
          });
        },
        onDragEnd: (_) {
          setState(() {
            isDrag = false;
          });
        },
        data: option[index],
        feedback: count.contains(option[index])
            ? Container(
                color: CColor.black,
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.33,
              )
            : Image.asset(
                totalImages[option[index]].toString(),
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
        child: count.contains(option[index])
            ? Container(
                color: CColor.transparent,
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.33,
              )
            : Image.asset(
                totalImages[option[index]].toString(),
              ),
        childWhenDragging: Container(
          color: CColor.transparent,
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.33,
        ),
      ),
    );
  }

  generateImagesOptions() {
    startPos = -1.0;
    endPos = 0.0;
    curve = Curves.elasticOut;
    option.clear();
    // que.clear();
    count.clear();
    listDraggableData.clear();

    option = totalImages.keys.toList().sample(4);
    Debug.printLog("New Matching Numbers==>> " + option.toString());
    for (var element in option) {
      // que.add(totalImages[element]!);
      Debug.printLog("Total Numbers Element==>>> " +
          element +
          "  " +
          totalImages[element].toString());
      listDraggableData.add(DraggableImagesData(totalImages[element], false));
    }
    // que.shuffle();
    listDraggableData.shuffle();

    setState(() {});
  }

  _slidingTrain() {
    return Expanded(
      child: TweenAnimationBuilder(
        tween:
            Tween<Offset>(begin: Offset(startPos, 0), end: Offset(endPos, 0)),
        duration: const Duration(seconds: 1),
        curve: curve,
        builder: (context, value, child) {
          return FractionalTranslation(
            translation: value as Offset,
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Image.asset(
              "assets/icons/train/train_drag.webp",
              scale: 2.5,
            ),
            Container(
              margin:
                  EdgeInsets.only(right: Sizes.width_3, bottom: Sizes.height_2),
              child: _dragTargetImage(context),
            ),
          ],
        ),
        onEnd: () {
          Debug.printLog('onEnd');
        },
      ),
    );
  }

  _dragTargetImage(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DragTarget(
          builder: (BuildContext context, List<Object?> candidateData,
              List<dynamic> rejectedData) {
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.width_5, vertical: Sizes.height_1),
              child: (listDraggableData
                  .where((element) => element.isRemoved == false)
                  .toList()
                  .isNotEmpty)?Image.asset(
                // "assets/images/train/apple.webp",
                listDraggableData
                    .where((element) => element.isRemoved == false)
                    .toList()[0]
                    .imageName!,
                scale: 3,
              ):Container(),
            );
          },
          onWillAccept: (data) {
            if (totalImages[data] ==
                listDraggableData
                    .where((element) => element.isRemoved == false)
                    .toList()[0]
                    .imageName!) {
              // if (!isDrag!) {
              Debug.printLog("accept==>> " + totalImages[data].toString());
              // }
              return true;
            } else {
              // if (!isDrag!) {
              Debug.printLog("reject==>> " + totalImages[data].toString());
              // }
              return false;
            }
          },
          onAccept: (data) async {
            setState(() {
              accept = true;
            });
            if (count.length < 4) {
              setState(() {
                count.add(data.toString());
                var selectedObjectIndex = listDraggableData
                    .indexWhere((element) => element.imageName == current);
                Debug.printLog("que:==>>  " +
                    listDraggableData[selectedObjectIndex]
                        .imageName
                        .toString() +
                    "  " +
                    selectedObjectIndex.toString());
                var removedObjectIndex = listDraggableData.indexWhere(
                    (element) =>
                        element.imageName ==
                        listDraggableData[selectedObjectIndex]
                            .imageName
                            .toString());
                listDraggableData[removedObjectIndex].isRemoved = true;
                Utils.playSound("assets/sounds/matching/intelligent.mp3");
              });

              await Future.delayed(const Duration(milliseconds: 100), () {
                setState(() {
                  accept = false;
                });
              });
            }

            if (count.length == 4) {
              isLottieLoad = true;
              setState(() {
                curve = curve == Curves.elasticOut
                    ? Curves.elasticIn
                    : Curves.elasticOut;
                if (startPos == -1) {
                  startPos = 0.0;
                  endPos = 1.0;
                }
              });
              await Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  isLottieLoad = false;
                  generateImagesOptions();
                });
              });
            }
            Debug.printLog("onAccept==>>>> " + data.toString());
          },
          onLeave: (data) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!isDrag!) {
                Debug.printLog("onLeave==>>>> " +
                    data.toString() +
                    "  " +
                    isDrag.toString());
                Utils.playSound("assets/sounds/quiz/wrong_answer.mp3");
              }
            });
          },
          onAcceptWithDetails: (details) {
            Debug.printLog(
                "onAcceptWithDetails===>> " + details.data.toString());
          },
        ),
      ],
    );
  }
}

class DraggableImagesData {
  String? imageName;
  bool isRemoved = false;

  DraggableImagesData(this.imageName, this.isRemoved);
}
