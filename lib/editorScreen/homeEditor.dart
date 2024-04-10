import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editor/editorScreen/ImageShowScreen.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:image/image.dart' as imageLib;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themed/themed.dart';
import 'package:bitmap/bitmap.dart';
import 'package:toast/toast.dart';
import 'package:widget_to_image/widget_to_image.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomeEditor extends StatefulWidget {
  final image;

  const HomeEditor({Key? key, required this.image}) : super(key: key);

  @override
  State<HomeEditor> createState() => _HomeEditorState(imagePath: image);
}

class _HomeEditorState extends State<HomeEditor> {
  ByteData? _byteData;
  GlobalKey _globalKey = GlobalKey();
  final imagePath;
  var image;
  late File imageFile = File("");

  _HomeEditorState({this.imagePath});

  double imageWidthHeight = 0.0;
  double blurImage = 5.0;

  double brightnessValue = 0.0;
  double saturationValue = 0.0;
  double hueValue = 0.0;
  double contrastValue = 1.0;

  int bottomIndex = 0;
  int selectedFrame = 0;
  bool frameBarVisible = false;
  bool adJustBarVisible = false;
  bool isAdjustOn = false;
  bool brightnessBarVisible = false;
  bool saturationBarVisible = false;
  bool hueBarVisible = false;
  bool contrasrBarVisible = false;
  Color adjustButtonColor = Colors.white70;
  Bitmap filteredBitmap = Bitmap.blank(200, 200);

  final defaultColorMatrix = const <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];

  late String filename;

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  List frame = [
    "assets/trans.png",
    "assets/01.png",
    "assets/02.png",
    "assets/03.jpg",
    "assets/04.png",
    "assets/05.jpg",
    "assets/06.png",
    "assets/07.jpg",
    "assets/08.png"
  ];
  Bitmap bitmap = Bitmap.blank(100, 100);
  Matrix4 transform = Matrix4.identity();
  bool isAdjustIntroShowed = false;

  @override
  void initState() {
    setState(() {
      super.initState();
      imageFile = File(imagePath);
      filename = basename(imageFile.path);
      getBtiampFromImage();
      transform = Matrix4.identity();

      getAdjustIntro();
    });
  }

  // @override
  // void initState() {
  //   setState(() {
  //     super.initState();
  //
  //     getB();
  //     debugPrint("ASDASDADDASDASD : ${bitmap}");
  //
  //     // WidgetsBinding.instance.addPostFrameCallback((_) => {
  //     // });
  //   });
  // }

  void getB() async {
    bitmap = await Bitmap.fromProvider(FileImage(File(image)));
  }

  @override
  Widget build(BuildContext context) {
    getHeightWidth(context);
    // ToastContext().init(context);

    // getBtiampFromImage();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Screen"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _saveScreen(context);
                },
                icon: Icon(Icons.save)),
          ],
        ),
        body: Container(
            child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              // color: adjustButtonColor,
                              onPressed: () {
                                setState(() {
                                  if (!isAdjustIntroShowed) {
                                    isIntroShow = true;
                                    setAdjustIntro(true);
                                  } else {
                                    isIntroShow = false;
                                  }

                                  getAdjustIntro();

                                  if (isAdjustOn) {
                                    isAdjustOn = false;
                                    adjustButtonColor = Colors.white70;
                                    frameBarVisible = false;
                                    brightnessBarVisible = false;
                                    adJustBarVisible = false;
                                    hueBarVisible = false;
                                  } else {
                                    isAdjustOn = true;
                                    adjustButtonColor = Colors.green;
                                    frameBarVisible = false;
                                    brightnessBarVisible = false;
                                    adJustBarVisible = false;
                                    hueBarVisible = false;
                                  }
                                });
                              },
                              child: Text("Adjust")),
                        ],
                      )),
                    )),
                Expanded(
                    flex: 6,
                    child: Container(
                        // panEnabled: true,
                        // height: imageWidthHeight,
                        child: Center(
                            child: RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  // height: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(imagePath)),
                                  )),
                                  // color: Colors.blue,
                                ),
                              ),
                              Center(
                                child: Positioned(
                                  child: ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: blurImage, sigmaY: blurImage),
                                      child: Container(
                                        // height: MediaQuery.of(context).size.width,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          MatrixGestureDetector(
                            onMatrixUpdate: (m, rs, ry, rx) {
                              setState(() {
                                transform = m;
                              });
                            },
                            child: Container(
                              transform: transform,
                              child: Center(
                                child: Container(
                                  color: Colors.transparent,
                                  // height: imageWidthHeight,
                                  child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(
                                          calculateContrastMatrix(
                                              contrastValue)),
                                      child: ChangeColors(
                                        hue: hueValue,
                                        saturation: saturationValue,
                                        brightness: brightnessValue,
                                        child: Image.file(imageFile),
                                      )),
                                ),
                              ),
                            ),
                          ),
                          addFrameContainer(),
                        ],
                      ),
                    )))),
                Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        Visibility(
                          visible: frameBarVisible,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: Positioned(
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Container(
                                  height: 60,
                                  child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: getAllFrames())),
                              // ),
                            ),
                          ),
                        ),
                        Positioned(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Container(
                              height: 72,
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: brightnessBarVisible,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 72,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 7,
                                                right: 7,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    adJustBarVisible = true;
                                                    brightnessBarVisible =
                                                        false;
                                                  });
                                                },
                                                child: Container(
                                                    width: 10,
                                                    child: Icon(
                                                      Icons
                                                          .arrow_back_ios_sharp,
                                                      size: 20,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Slider(
                                                  min: -1,
                                                  max: 1,
                                                  value: brightnessValue,
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      brightnessValue = value;
                                                    });
                                                  }),
                                            )
                                          ],
                                        )),
                                  ),
                                  Visibility(
                                    visible: saturationBarVisible,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 72,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 7,
                                                right: 7,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    adJustBarVisible = true;
                                                    saturationBarVisible =
                                                        false;
                                                  });
                                                },
                                                child: Container(
                                                    width: 10,
                                                    child: Icon(
                                                      Icons
                                                          .arrow_back_ios_sharp,
                                                      size: 20,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Slider(
                                                  min: -1,
                                                  max: 1,
                                                  value: saturationValue,
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      saturationValue = value;
                                                    });
                                                  }),
                                            )
                                          ],
                                        )),
                                  ),
                                  Visibility(
                                    visible: contrasrBarVisible,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 72,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 7,
                                                right: 7,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    adJustBarVisible = true;
                                                    saturationBarVisible =
                                                        false;
                                                    contrasrBarVisible = false;
                                                  });
                                                },
                                                child: Container(
                                                    width: 10,
                                                    child: Icon(
                                                      Icons
                                                          .arrow_back_ios_sharp,
                                                      size: 20,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Slider(
                                                  min: 0,
                                                  max: 4,
                                                  value: contrastValue,
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      contrastValue = value;
                                                    });
                                                  }),
                                            )
                                          ],
                                        )),
                                  ),
                                  Visibility(
                                    visible: adJustBarVisible,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black,
                                      height: 72,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                adJustBarVisible = false;
                                                brightnessBarVisible = true;
                                                hueBarVisible = false;
                                                saturationBarVisible = false;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.brightness_5_sharp,
                                                  color: Colors.white,
                                                ),
                                                Text("Brigthness",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                adJustBarVisible = false;
                                                saturationBarVisible = false;
                                                brightnessBarVisible = false;
                                                hueBarVisible = false;
                                                contrasrBarVisible = true;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.contrast_sharp,
                                                  color: Colors.white,
                                                ),
                                                Text("Constrast",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                adJustBarVisible = false;
                                                saturationBarVisible = false;
                                                brightnessBarVisible = false;
                                                hueBarVisible = true;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.heat_pump,
                                                  color: Colors.white,
                                                ),
                                                Text("Hue",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                adJustBarVisible = false;
                                                saturationBarVisible = true;
                                                brightnessBarVisible = false;
                                                hueBarVisible = false;
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.water_drop_outlined,
                                                  color: Colors.white,
                                                ),
                                                Text("Saturation",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.menu,
                                                  color: Colors.white,
                                                ),
                                                Text("Fade",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: hueBarVisible,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 72,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 7,
                                                right: 7,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    adJustBarVisible = true;
                                                    brightnessBarVisible =
                                                        false;
                                                    hueBarVisible = false;
                                                  });
                                                },
                                                child: Container(
                                                    width: 10,
                                                    child: Icon(
                                                      Icons
                                                          .arrow_back_ios_sharp,
                                                      size: 20,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Slider(
                                                  min: -1,
                                                  max: 1,
                                                  value: hueValue,
                                                  onChanged: (double value) {
                                                    setState(() {
                                                      hueValue = value;
                                                    });
                                                  }),
                                            )
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
              ],
            ),
            introAboutAdjust(),
          ],
        )),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomIndex,
          onTap: (int value) {
            setState(() {
              print("click bottom bar");

              if (!isAdjustOn) {
                bottomIndex = value;
                brightnessBarVisible = false;
                saturationBarVisible = false;
                hueBarVisible = false;
                contrasrBarVisible = false;

                if (bottomIndex == 0) {
                  // if(isAdjustOn==false){
                  // }
                  setState(() {
                    brightnessValue = 0;
                    saturationValue = 0;
                    hueValue = 0;
                    selectedFrame = 0;
                    contrastValue = 1;
                  });
                  frameBarVisible = false;
                  adJustBarVisible = false;
                } else if (bottomIndex == 1) {
                  if (isAdjustOn) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please off adjust button"),
                    ));
                  }
                  adJustBarVisible = false;

                  if (!frameBarVisible) {
                    frameBarVisible = true;
                  } else {
                    frameBarVisible = false;
                  }
                } else if (bottomIndex == 2) {
                  frameBarVisible = false;

                  if (!adJustBarVisible) {
                    adJustBarVisible = true;
                  } else {
                    adJustBarVisible = false;
                  }
                } else if (bottomIndex == 3) {
                  frameBarVisible = false;
                  adJustBarVisible = false;
                  setState(() async {
                    Map imagefile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhotoFilterSelector(
                                title: const Text("Photo Filter Example"),
                                filters: presetFiltersList,
                                image: image,
                                filename: filename,
                                loader: const Center(
                                    child: CircularProgressIndicator()),
                                fit: BoxFit.contain,
                                circleShape: false,
                              )),
                    );
                    if (imagefile != null &&
                        imageFile != "" &&
                        imagefile.containsKey('image_filtered')) {
                      setState(() {
                        imageFile = imagefile['image_filtered'];
                      });
                      print("sdasdsadas ${imageFile.path}");
                    }
                  });
                }
              } else {
                Fluttertoast.showToast(msg: "PLease First Turn Off Adjust");
              }
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.crop_original_outlined),
                label: 'Original',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_frames_outlined),
                label: 'Frames',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.adjust),
                label: 'Adjust',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.ac_unit_sharp),
                label: 'Filter',
                backgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }

  void getHeightWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    imageWidthHeight = width < height ? width : height;
  }

  List<Widget> getAllFrames() {
    List<Widget> widgets = [];
    for (int i = 0; i < frame.length; i++) {
      widgets.add(GestureDetector(
        child: Container(
          margin: EdgeInsets.all(5),
          child: Image.asset(frame[i]),
        ),
        onTap: () {
          setState(() {
            selectedFrame = i;
          });
        },
      ));
    }
    return widgets;
  }

  Widget addFrameContainer() {
    return Visibility(
      visible: !isAdjustOn,
      child: Center(
        child: Image.asset(
          getSelectedFrame(),
          width: imageWidthHeight,
          height: imageWidthHeight,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  String getSelectedFrame() {
    if (selectedFrame == 0) {
      return "assets/trans.png";
    }
    return frame[selectedFrame];
  }

  void getBtiampFromImage() async {
    image = imageLib.decodeImage(await imageFile.readAsBytes());
    // image = imageLib.copyResize(image!, width: 600);
  }

  _saveScreen(BuildContext context) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);

    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png)
        as FutureOr<ByteData?>);

    String dir = (await getApplicationSupportDirectory()).path;
    final appDirectory = Directory(dir + "/PhotoEditor");

    if ((await appDirectory.exists())) {
      print("exist : ${appDirectory}");
    } else {
      print("not exist : ${appDirectory}");
      appDirectory.create();
    }

    String fullPath = appDirectory.path + "/abc.png";
    File file = File(fullPath);
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    //save image in file
    GallerySaver.saveImage(file.path);

    if (byteData != null) {
      // final result = await ImageGallerySaver.saveImage(
      //     byteData.buffer.asUint8List(),
      //     quality: 100);

      // print("asdasdsadasdsddasdsadasdasdd $result");

      Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: shareScreen(
              filePath: file.path,
            ),
            inheritTheme: true,
            ctx: context),
      );
    }
  }

  bool isIntroShow = false;

  Widget introAboutAdjust() {
    return Visibility(
      visible: isIntroShow,
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/IMAGE.jpg"),
              SizedBox(
                height: 25,
              ),
              Text("SEtting About Adjust Button"),
              SizedBox(
                height: 25,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isIntroShow = false;
                    });
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getAdjustIntro() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isAdjustIntroShowed = prefs.getBool("isAdjustIntroShowed")!;
      print("ssadsadsadsad :;;;;; ${isAdjustIntroShowed}");
    } catch (e) {}
  }

  void setAdjustIntro(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isAdjustIntroShowed", value);
  }
// MemoryImage getBtiampFromImage() {
//   filteredBitmap = bitmap.applyBatch([
//     BitmapBrightness(brightnessValue),
//     BitmapAdjustColor(
//       saturation: saturationValue,
//       exposure: exposureValue,
//     ),
//     // // whites: saturationValue),
//     // BitmapContrast(2),
//   ]);
//   print("BITMAP: ${bitmap} \n FILTERBT>>>>>>>> : ${filteredBitmap}");
//
//   // return filteredBitmap;
//   return MemoryImage(filteredBitmap.buildHeaded());
// }
}
