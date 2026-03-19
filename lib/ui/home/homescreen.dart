import 'dart:io';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_numbers_flutter/database/database_helper.dart';
import 'package:learn_numbers_flutter/database/tables/game_category_table.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  List<GamesCategoryTable> gamesCategoryList = [];
  ScrollController listGameController = ScrollController();
  final itemKey = GlobalKey();
  int currentPageValue = 0;
  PageController pageController =
      PageController(initialPage: 0, keepPage: true, viewportFraction: 0.25);
  RateMyApp? rateMyApp;
  bool? isSound;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused){
      if(Utils.audioPlayer != null) Utils.audioPlayer.stop();
    }else if(state == AppLifecycleState.resumed){
      if(Utils.audioPlayer != null) Utils.audioPlayer.resume();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCategoryData();
    _getPreference();
    initRateUs();
  }

  initRateUs(){

    rateMyApp = RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 7,
        minLaunches: 10,
        remindDays: 7,
        remindLaunches: 10,
        googlePlayIdentifier: Constant.googlePlayIdentifier,
        appStoreIdentifier: Constant.appStoreIdentifier
    );
    if (Platform.isIOS) {
      rateMyApp!.init().then((_) {
        if (rateMyApp!.shouldOpenDialog) {
          rateMyApp!.showRateDialog(
            context,
            title: 'Rate this app',
            message:
            'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
            rateButton: 'RATE',
            noButton: 'NO THANKS',
            laterButton: 'MAYBE LATER',
            listener: (button) {
              switch (button) {
                case RateMyAppDialogButton.rate:
                  break;
                case RateMyAppDialogButton.later:
                  break;
                case RateMyAppDialogButton.no:
                  break;
              }

              return true;
            },
            ignoreNativeDialog: Platform.isAndroid,
            dialogStyle: const DialogStyle(),
            onDismissed: () =>
                rateMyApp!.callEvent(RateMyAppEventType.laterButtonPressed),
          );

          rateMyApp!.showStarRateDialog(
            context,
            title: 'Rate this app',
            message:
            'You like this app ? Then take a little bit of your time to leave a rating :',
            actionsBuilder: (context, stars) {
              return [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    await rateMyApp!
                        .callEvent(RateMyAppEventType.rateButtonPressed);
                    Navigator.pop<RateMyAppDialogButton>(
                        context, RateMyAppDialogButton.rate);
                  },
                ),
              ];
            },
            ignoreNativeDialog: Platform.isAndroid,
            dialogStyle: const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
            starRatingOptions: const StarRatingOptions(),
            onDismissed: () =>
                rateMyApp!.callEvent(RateMyAppEventType.laterButtonPressed),
          );
        }
      });
    }

  }

  _getPreference() {
    isSound = Preference.shared.getBool(Preference.isMusic) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/home/main_bg.webp",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SafeArea(
            bottom: (Platform.isIOS) ? false : true,
            top: false,
            right: true,
            left: false,
            child: Sizer(
              builder: (BuildContext context, Orientation orientation,
                  DeviceType deviceType) {
                return Column(
                  children: [
                    _widgetTopView(),
                    _widgetCenterView(),
                    _widgetBottomView(),
                  ],
                );
              },
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
          left: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2,
          right: (Platform.isIOS) ? Sizes.width_5 : Sizes.width_2),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              openDialogForExits();
            },
            child: Image.asset(
              "assets/icons/home/ic_close.webp",
              scale: 6,
            ),
          ),
          InkWell(
            onTap: () {
              Utils.launchFacebook();
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                "assets/icons/home/ic_share_fb.webp",
                scale: 6,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Utils.launchURLForYouTube();
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                "assets/icons/home/ic_youtube.webp",
                scale: 6,
              ),
            ),
          ),
          Expanded(child: Container()),
          InkWell(
            onTap: () {
              _sound();
            },
            child: Image.asset(
              (isSound!)
                  ? "assets/icons/home/ic_sound.webp"
                  : "assets/icons/home/ic_sound_off.webp",
              scale: 6,
            ),
          ),
          /*Container(
            margin: EdgeInsets.only(left: Sizes.width_2),
            child: Image.asset(
              "assets/icons/home/ic_remove_ad.webp",
              scale: 6,
            ),
          ),*/
          InkWell(
            onTap: () {
              _rate();
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                "assets/icons/home/ic_rate_us.webp",
                scale: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _widgetCenterView() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            bottom: Sizes.height_1,
            left: (Platform.isIOS) ? Sizes.width_6 : Sizes.width_1),
        child: PageView.builder(
          itemCount: gamesCategoryList.length,
          controller: pageController,
          padEnds: false,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (value) {
            setState(() {
              currentPageValue = value;
            });
          },
          itemBuilder: (BuildContext context, int itemIndex) {
            return _itemGamesCategory(itemIndex);
          },
        ),
      ),
    );
  }

  _widgetBottomView() {
    return Container(
      margin: EdgeInsets.only(bottom: Sizes.height_0_5, top: Sizes.height_0_5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              // pageController.previousPage(duration: const Duration(milliseconds: 1), curve: Curves.ease);
              Debug.printLog("pageController previousPage ==>>> " +
                  pageController.page.toString());
              pageController.jumpToPage(pageController.page!.toInt() - 3);
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                "assets/icons/home/ic_previous.webp",
                scale: 6,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              // pageController.nextPage(duration: const Duration(milliseconds: 1), curve: Curves.ease);
              Debug.printLog("pageController nextPage==>>> " +
                  pageController.page.toString());
              pageController.jumpToPage(pageController.page!.toInt() + 3);
            },
            child: Container(
              margin: EdgeInsets.only(left: Sizes.width_2),
              child: Image.asset(
                "assets/icons/home/ic_next.webp",
                scale: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*_itemGamesCategory(int index) {
    return InkWell(
      onTap: () {
        if(gamesCategoryList[index].moveScreen.toString().isNotEmpty) {
          Navigator.pushNamed(
              context, "/"+gamesCategoryList[index].moveScreen.toString());
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            // margin: EdgeInsets.symmetric(horizontal: Sizes.width_2,vertical: Sizes.height_1),
            margin: EdgeInsets.only(left:  Sizes.width_2,right:  Sizes.width_2,
                top: Sizes.height_1,bottom: Sizes.height_3_5),
            width: Sizes.width_45,
            decoration: const BoxDecoration(
              color: CColor.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: CColor.yellowShadow,
                    offset: Offset(0.0, 5.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                ],
              borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: Sizes.height_3,top: Sizes.height_1),
              // child: Image.asset("assets/images/img_game_quiz.webp"),
              child: Image.asset(gamesCategoryList[index].image.toString()),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: Sizes.width_1),
            width: Sizes.width_40,
            decoration: BoxDecoration(
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: CColor.shadowColor,
                      blurRadius: 1.0,
                      offset: Offset(0.0, 0.90)
                  )
                ],
              borderRadius: BorderRadius.circular(25),
              gradient:CColor.gradientColor
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Sizes.height_2),
                child: AutoSizeText(
                  gamesCategoryList[index].gameName.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "MochiyPop",
                    fontWeight: FontWeight.w400,
                    color: CColor.white,
                    fontSize: FontSize.size_15,
                  ),
              ),
            ),
          )
        ],
      ),
    );
  }*/

  _itemGamesCategory(int index) {
    return InkWell(
      onTap: () {
        if (gamesCategoryList[index].moveScreen.toString().isNotEmpty) {
          Navigator.pushNamed(
              context, "/" + gamesCategoryList[index].moveScreen.toString());
        }
      },
      child: Container(
        // color: CColor.black,
        margin: EdgeInsets.only(
          right: Sizes.height_1,
          left: Sizes.height_1,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              // margin: EdgeInsets.symmetric(horizontal: Sizes.width_2,vertical: Sizes.height_1),
              margin: EdgeInsets.only(
                bottom: (Platform.isIOS) ? Sizes.height_2 : Sizes.height_3,
                top: (Platform.isIOS) ? Sizes.height_1 : Sizes.height_0,
              ),
              child: Image.asset(
                gamesCategoryList[index].image.toString(),
                width: Sizes.width_50,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: Sizes.height_1,
                left: Sizes.height_1,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/icons/home/ic_btn_blue_home.webp",
                    width: Sizes.width_45,
                  ),
                  AutoSizeText(
                    gamesCategoryList[index].gameName.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "MochiyPop",
                      fontWeight: FontWeight.w400,
                      color: CColor.white,
                      fontSize: FontSize.size_15,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _getCategoryData() async {
    gamesCategoryList = await DataBaseHelper().getAllGamesCategory();
    Debug.printLog(
        "_getCategoryData==>> " + gamesCategoryList.length.toString());
    setState(() {});
  }

  openDialogForExits() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Text(
                Languages.of(context)!.txtAreYouSureYouWantToExit,
              ),
              actions: [
                TextButton(
                  child: Text(Languages.of(context)!.txtNo.toUpperCase(),
                      style: const TextStyle(color: CColor.black)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    Languages.of(context)!.txtYes.toUpperCase(),
                    style: const TextStyle(color: CColor.black),
                  ),
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                )
              ]);
        });
  }

  _sound() {
    if (isSound!) {
      Preference.shared.setBool(Preference.isMusic, false);
      setState(() {
        _getPreference();
        Utils.playAudioForBg("Home",false);
      });
    } else {
      Preference.shared.setBool(Preference.isMusic, true);
      setState(() {
        _getPreference();
        Utils.playAudioForBg("Home",true);
      });
    }
  }

  _rate() {
    if (Platform.isIOS) {
      rateMyApp!.showRateDialog(context);
    } else {
      rateMyApp!.launchStore();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
