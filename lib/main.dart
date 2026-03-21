import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_numbers_flutter/ui/colorscreen/colorscreen.dart';
import 'package:learn_numbers_flutter/ui/modeselect/modeselectscreen.dart';
import 'package:learn_numbers_flutter/ui/countscreen/countscreen.dart';
import 'package:learn_numbers_flutter/ui/gamescreen/gamescreen.dart';
import 'package:learn_numbers_flutter/ui/home/homescreen.dart';
import 'package:learn_numbers_flutter/ui/learnscreen/learnscreen.dart';
import 'package:learn_numbers_flutter/ui/matchingscreen/matchingscreen.dart';
import 'package:learn_numbers_flutter/ui/pairscreen/pairscreen.dart';
import 'package:learn_numbers_flutter/ui/practicescreen/practicescreen.dart';
import 'package:learn_numbers_flutter/ui/quizscreen/quizscreen.dart';
import 'package:learn_numbers_flutter/ui/sequencescreen/sequencescreen.dart';
import 'package:learn_numbers_flutter/ui/sortingscreen/sortingscreen.dart';
import 'package:learn_numbers_flutter/ui/spotit/spotitscreen.dart';
import 'package:learn_numbers_flutter/ui/tracingScreen/tracingScreen.dart';
import 'package:learn_numbers_flutter/ui/trainscreen/trainscreen.dart';
import 'package:learn_numbers_flutter/ui/writescreen/writescreen.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:learn_numbers_flutter/utils/preference.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preference().instance();

  RequestConfiguration conf= RequestConfiguration(tagForChildDirectedTreatment: 1);
  MobileAds.instance.updateRequestConfiguration(conf);
  await MobileAds.instance.initialize();
  runApp(const MyApp());

}


class MyApp extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> scaffoldKey =
  GlobalKey<ScaffoldState>();



  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  Locale? _locale;
  bool isFirstTimeUser = true;
  bool? isSound;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _getPreference() {
    isSound = Preference.shared.getBool(Preference.isMusic) ?? true;
  }

  @override
  void didChangeDependencies() async {
    _locale = getLocale();

    super.didChangeDependencies();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    Debug.printLog(
        "AppLifecycleState.didChangeAppLifecycleState state.....  $state");
    if (state == AppLifecycleState.resumed) {
      _getPreference();
      Debug.printLog(
          "AppLifecycleState.resumed.....  ${Preference.shared.getBool(Preference.isMusic).toString()}");
      if (Preference.shared.getBool(Preference.isMusic) ?? true) {
        Utils.playAudioForBg("resumed", true);
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _getPreference();
      Debug.printLog(
          "AppLifecycleState.resumed else.....  ${Preference.shared.getBool(Preference.isMusic).toString()}");
      if (Preference.shared.getBool(Preference.isMusic) ?? true) {
        Utils.playAudioForBg("resumed", false);
      }
    }
  }



  @override
  void initState() {
    isFirstTime();
    _getPreference();
    Future.delayed(const Duration(seconds: 1), () {
      if (Preference.shared.getBool(Preference.isMusic) ?? true) {
        Utils.playAudioForBg("initState",true);
      }
    });

    super.initState();
  }

  isFirstTime() async {
    isFirstTimeUser =
        Preference.shared.getBool(Preference.isUserFirsttime) ?? true;
    Debug.printLog(isFirstTimeUser.toString());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);


    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      theme: ThemeData(
        splashColor: CColor.transparent,
        highlightColor: CColor.transparent,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      darkTheme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: CColor.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark),
      ),
      home: const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: CColor.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: const ModeSelectScreen(),
      ),
      routes: <String, WidgetBuilder>{
        '/modeSelect': (BuildContext context) => const ModeSelectScreen(),
        '/homeScreen': (BuildContext context) => const HomeScreen(),
        '/learnScreen': (BuildContext context) => const LearnScreen(),
        '/countScreen': (BuildContext context) => const CountScreen(),
        '/quizScreen': (BuildContext context) => const QuizScreen(),
        '/pairScreen': (BuildContext context) => const PairScreen(),
        '/matchingScreen': (BuildContext context) => const MatchingScreen(),
        '/sequenceScreen': (BuildContext context) => const SequenceScreen(),
        '/tracingScreen': (BuildContext context) => const TracingScreen(),
        '/gameScreen': (BuildContext context) => const GameScreen(),
        '/practiceScreen': (BuildContext context) => const PracticeScreen(),
        '/trainScreen': (BuildContext context) => const TrainScreen(),
        '/spotItScreen': (BuildContext context) => const SpotItScreen(),
        '/sortingScreen': (BuildContext context) => const SortingScreen(),
        '/writeScreen': (BuildContext context) => const WriteScreen(),
        '/coloringScreen': (BuildContext context) => const ColorScreen(),
      },
    );
  }
}
