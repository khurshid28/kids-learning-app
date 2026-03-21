import 'package:learn_numbers_flutter/database/tables/colors_pic_table.dart';
import 'package:learn_numbers_flutter/utils/debug.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:learn_numbers_flutter/localization/language/languages.dart';
import 'package:learn_numbers_flutter/utils/color.dart';
import 'package:learn_numbers_flutter/utils/utils.dart';
import 'package:learn_numbers_flutter/utils/constant.dart';
import 'package:learn_numbers_flutter/utils/sizer_utils.dart';
import 'package:floodfill_image/floodfill_image.dart';
import 'package:learn_numbers_flutter/utils/letters_data.dart';

class ColorsPaintScreen extends StatefulWidget {
  // final String? imgName;
  final List<ColorsPicTable>? colorsPicDataList;

  final int? selectedPos;
  final bool isLettersMode;

  const ColorsPaintScreen({Key? key, this.colorsPicDataList, this.selectedPos, this.isLettersMode = false})
      : super(key: key);

  @override
  _ColorsPaintScreenState createState() => _ColorsPaintScreenState();
}

class _ColorsPaintScreenState extends State<ColorsPaintScreen> {
  // String? imgName;
  String? typeOfColor;
  final bool finished = false;
  int selectedColorIndex = 0;
  bool isVisiblePenDotWidget = false;
  bool isVisibleColorWidget = false;
  PageController? pageController;
  Uint8List? imageFile;
  int _currentPage = 0;

  // GlobalKey previewContainer = GlobalKey();

  Color? fillColor;

  @override
  void initState() {
    // imgName = widget.imgName;
    Utils.requestPermission();
    typeOfColor = Constant.typeRound;
    _currentPage = widget.selectedPos!;
    pageController = PageController(
        initialPage: widget.selectedPos!, keepPage: true, viewportFraction: 1);
    playSoundForNumbers(widget.selectedPos! + 1);
    widget.colorsPicDataList![widget.selectedPos!].previewContainer =
        GlobalKey();
    fillColor = CColor.c1;
    super.initState();
  }

  playSoundForNumbers(int pos) {
    if (widget.isLettersMode) {
      final letter = LettersData.letters[pos - 1];
      Utils.playSound(LettersData.soundPath(letter));
    } else {
      Utils.playSound("assets/sounds/learn/n_" + pos.toString() + ".mp3");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: (Platform.isIOS) ? false : true,
        top: false,
        right: true,
        left: false,
        child: Row(
          children: [
            _widgetFirstView(),
            _widgetCenterView(),
            _widgetLastView(),
          ],
        ),
      ),
    );
  }

  Widget _letterBadge() {
    final letter = LettersData.letters[_currentPage];
    return GestureDetector(
      onTap: () => playSoundForNumbers(_currentPage + 1),
      child: Container(
        margin: EdgeInsets.only(
            right: Sizes.width_1_5, left: Sizes.width_1_5, top: Sizes.height_1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontSize.size_30,
                fontFamily: 'MochiyPop',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(1, 2))
                ],
              ),
            ),
            SizedBox(height: Sizes.height_0_5),
            Image.asset(
              LettersData.letterObjects[letter]!,
              height: Sizes.height_5,
            ),
          ],
        ),
      ),
    );
  }

  _widgetFirstView() {
    return Stack(
      children: [
        Image.asset(
          "assets/images/tracing/left_header_bg.webp",
          color: CColor.colorRoundAll[selectedColorIndex],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.isLettersMode) Expanded(child: Center(child: _letterBadge())),
            Expanded(
              child: InkWell(
                onTap: () {
                  playSoundForNumbers(pageController!.page!.toInt() + 1);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: Sizes.width_3,
                      left: Sizes.width_1_5,
                      top: Sizes.height_4),
                  child: Image.asset(
                    "assets/icons/tracing/ic_tracing_sound.webp",
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  capturePic();
                  // var status = await Permission.storage.status;
                  // if (status.isGranted) {
                  //   capturePng(context).then((value) => Utils.showToast(
                  //       context, Languages.of(context)!.txtSaveSuccess));
                  // } else if (status.isDenied) {
                  //   capturePng(context).then((value) => Utils.showToast(
                  //       context, Languages.of(context)!.txtSaveSuccess));
                  // } else {
                  //   showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) => CupertinoAlertDialog(
                  //             title: const Text('Storage Permission'),
                  //             content:
                  //                 const Text('This app needs storage access.'),
                  //             actions: <Widget>[
                  //               CupertinoDialogAction(
                  //                 child: const Text('Deny'),
                  //                 onPressed: () => Navigator.of(context).pop(),
                  //               ),
                  //               CupertinoDialogAction(
                  //                 child: const Text('Settings'),
                  //                 onPressed: () => openAppSettings(),
                  //               ),
                  //             ],
                  //           ));
                  // }
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: Sizes.width_3,
                      left: Sizes.width_1_5,
                      top: Sizes.height_4),
                  child: Image.asset(
                    "assets/icons/tracing/ic_tracing_camera.webp",
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  openDialogForCLearPaint();
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: Sizes.width_3,
                      left: Sizes.width_1_5,
                      top: Sizes.height_4),
                  child: Image.asset(
                    "assets/icons/tracing/ic_tracing_close.webp",
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: Sizes.width_3,
                      left: Sizes.width_1_5,
                      top: Sizes.height_4),
                  child: Image.asset(
                    "assets/icons/learn/ic_home.webp",
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  capturePic() async {
    try {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        final imgBytes = await capturePng(context);
        if (imgBytes != null) {
          Utils.showToast(context, Languages.of(context)!.txtSaveSuccess);
        } else {
          Utils.showToast(context, "Failed to capture image.");
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Storage Permission'),
            content: const Text('This app needs storage access.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('Deny'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: const Text('Settings'),
                onPressed: () => openAppSettings(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Debug.printLog("Permission Error: $e");
    }
  }

  Future<Uint8List?> capturePng(BuildContext context) async {
    try {
      RenderRepaintBoundary? boundary = widget
          .colorsPicDataList![pageController!.page!.toInt()]
          .previewContainer!
          .currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to public storage for Gallery
      const String folderPath = "/storage/emulated/0/Pictures/LearnNumbers";
      final Directory dir = Directory(folderPath);
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }

      final String filePath = "$folderPath/${DateTime.now().millisecondsSinceEpoch}.jpg";
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Optional: notify media scanner (so gallery app detects it)
      if (Platform.isAndroid) {
        final result = await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$filePath'
        ]);
        print("Media scanner result::::::::::::: ${result.exitCode}");
      }

      Debug.printLog("Image saved at: $filePath");
      return pngBytes;
    } catch (e) {
      Debug.printLog("Capture Error: $e");
      return null;
    }
  }

  // Future<Uint8List?> capturePng(BuildContext context) async {
  //   try {
  //     /*RenderRepaintBoundary? boundary = previewContainer.currentContext
  //         ?.findRenderObject() as RenderRepaintBoundary?;*/
  //     RenderRepaintBoundary? boundary = widget
  //         .colorsPicDataList![pageController!.page!.toInt()]
  //         .previewContainer!
  //         .currentContext
  //         ?.findRenderObject() as RenderRepaintBoundary?;
  //     ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);
  //     var pngBytes = byteData!.buffer.asUint8List();
  //     var bs64 = base64Encode(pngBytes);
  //
  //     Uint8List bytes = base64.decode(bs64);
  //
  //     final directory = await getApplicationDocumentsDirectory();
  //     File file = File(directory.path +
  //         "/" +
  //         DateTime.now().millisecondsSinceEpoch.toString() +
  //         ".jpg");
  //     await file.writeAsBytes(bytes);
  //     /*await GallerySaver.saveImage(file.path, albumName: "PatchiLockScreen")
  //         .then((value) => imageSaveOrNot = value);*/
  //
  //     /*await ImageGallerySaver.saveImage(bytes,
  //         quality: 100,
  //         name: "Numbers_${DateTime.now()}",
  //         isReturnImagePathOfIOS: true);*/
  //
  //     await GallerySaver.saveImage(file.path, albumName: "LearnNumbers")
  //         .then((value) =>  Debug.printLog("File path save Colors ===>>> " + value.toString()));
  //
  //
  //     Debug.printLog("File path save ===>>> " + file.path);
  //     return pngBytes;
  //   } catch (e) {
  //     Debug.printLog(e.toString());
  //   }
  // }

  _widgetCenterView() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            children: [
              PageView.builder(
                itemCount: widget.colorsPicDataList!.length,
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: (value) {
                  widget.colorsPicDataList![value].previewContainer =
                      GlobalKey();
                  playSoundForNumbers(value + 1);
                  setState(() { _currentPage = value; });
                },
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _itemAllNumbers(context, itemIndex);
                },
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        closePopUp();
                        pageController!.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      });
                    },
                    child: Image.asset(
                      "assets/images/tracing/ic_tracing_left.webp",
                      scale: 5,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        closePopUp();
                        pageController!.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      });
                    },
                    child: Image.asset(
                      "assets/images/tracing/ic_tracing_right.webp",
                      scale: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Visibility(
            visible: isVisiblePenDotWidget,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: Sizes.height_2_5, horizontal: Sizes.width_5),
              decoration: BoxDecoration(
                  border: Border.all(color: CColor.orange, width: 5),
                  color: CColor.black,
                  borderRadius: BorderRadius.circular(60)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/pen_ssmall_dot.webp",
                        scale: 6,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/pen_mmedium_dot.webp",
                        scale: 6,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/pen_bbig_dot.webp",
                        scale: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isVisibleColorWidget,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: Sizes.height_2_5, horizontal: Sizes.width_5),
              decoration: BoxDecoration(
                  border: Border.all(color: CColor.orange, width: 5),
                  color: CColor.black,
                  borderRadius: BorderRadius.circular(60)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        typeOfColor = Constant.typeRound;
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/round/c4.webp",
                        scale: 2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        typeOfColor = Constant.typeSquare;
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/square/g_5.webp",
                        scale: 2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        typeOfColor = Constant.typeOther;
                        closePopUp();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Sizes.width_1),
                      child: Image.asset(
                        "assets/icons/tracing/other/git_3.webp",
                        scale: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _widgetLastView() {
    return Stack(
      children: [
        Image.asset(
          "assets/images/tracing/right_header_bg.webp",
          color: CColor.colorRoundAll[selectedColorIndex],
        ),
        Stack(
          alignment: Alignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0,
              child: InkWell(
                /*onTap: () {
                    setState(() {
                      isVisiblePenDotWidget = false;
                      isVisibleColorWidget = !isVisibleColorWidget;
                    });
                  },*/
                child: Container(
                  margin: EdgeInsets.only(
                      left: Sizes.width_3,
                      right: Sizes.width_3,
                      top: Sizes.height_1),
                  child: Image.asset(
                    "assets/icons/tracing/ic_tracing_more.webp",
                    scale: 6,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: Sizes.height_2),
              child: SizedBox(
                width: Sizes.width_12,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemColorsDraw(index);
                  },
                  itemCount: CColor.colorRoundAll.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _itemColorsDraw(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: Sizes.height_2),
      child: (typeOfColor == Constant.typeRound)
          ? InkWell(
              onTap: () {
                setState(() {
                  selectedColorIndex = index;
                  fillColor = CColor.colorRoundAll[index];
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/icons/tracing/round/c" +
                      (index + 1).toString() +
                      ".webp"),
                  Visibility(
                    visible: (selectedColorIndex == index) ? true : false,
                    child: Container(
                      margin: EdgeInsets.only(bottom: Sizes.height_1),
                      child: Icon(
                        Icons.done_rounded,
                        color: CColor.white,
                        size: Sizes.height_4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : (typeOfColor == Constant.typeSquare)
              ? Image.asset("assets/icons/tracing/square/g_" +
                  (index + 1).toString() +
                  ".webp")
              : Image.asset("assets/icons/tracing/other/git_" +
                  (index + 1).toString() +
                  ".webp"),
    );
  }

  _itemAllNumbers(BuildContext context, int itemIndex) {
    return RepaintBoundary(
      // key: previewContainer,
      key: widget.colorsPicDataList![itemIndex].previewContainer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /*Image.asset(
            widget.colorsPicDataList![itemIndex].imgName.toString(),
            fit: BoxFit.cover,
          ),*/
          FloodFillImage(
            imageProvider: AssetImage(
                widget.colorsPicDataList![itemIndex].imgName.toString()),
            fillColor: fillColor!,
            avoidColor: const [Colors.white, Colors.black],
          ),
          /*InkWell(
            onTap: () {
              closePopUp();
            },
            child: Painter(painterController),
          ),*/
        ],
      ),
    );
  }

  void closePopUp() {
    setState(() {
      isVisibleColorWidget = false;
      isVisiblePenDotWidget = false;
    });
  }

  openDialogForCLearPaint() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              title: Text(
                Languages.of(context)!.txtAreYouSureYouWantToClear,
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
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                )
              ]);
        });
  }
}
