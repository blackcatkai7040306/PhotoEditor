import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_editor/editorScreen/homeEditor.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialization(null);
  FlutterNativeSplash.removeAfter(initialization);
  runApp(
    const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "PhotoEditor",
        home: MyApp()
    ),
  );
}


Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 2));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.menu,
                        size: 45,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        "InCollage",
                        style: TextStyle(
                          fontSize: 50,
                        ),
                      ),
                      const Icon(
                        Icons.add,
                        size: 50,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() async {
                            final _image = await _picker.pickImage(
                                source: ImageSource.gallery);

                            final imagePath = _image?.path;
                            Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: HomeEditor(image: imagePath),
                                  inheritTheme: true,
                                  ctx: context),
                            );
                          });
                        },
                        child: Card(
                          elevation: 5,
                          child: Column(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 15.0, left: 35, right: 35, bottom: 9),
                                child: Icon(
                                  Icons.edit,
                                  size: 90,
                                  color: Colors.blue,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("EDIT PAGE");
                        },
                        child: Card(
                          elevation: 5,
                          child: Column(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 15.0, left: 40, right: 40, bottom: 9),
                                child: Icon(
                                  Icons.grid_view,
                                  size: 90,
                                  color: Colors.pink,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                  "Grid",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, left: 2.0, bottom: 15.0, right: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  const Icon(
                                    Icons.add,
                                    size: 60,
                                  ),
                                  const Text(
                                    "FreeStyle",
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Column(
                                children: <Widget>[
                                  const Icon(
                                    Icons.add,
                                    size: 60,
                                  ),
                                  const Text(
                                    "Multi-fit",
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Column(
                                children: <Widget>[
                                  const Icon(
                                    Icons.add,
                                    size: 60,
                                  ),
                                  const Text(
                                    "Stitch",
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Column(
                                children: <Widget>[
                                  const Icon(
                                    Icons.add,
                                    size: 60,
                                  ),
                                  const Text(
                                    "Templates",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Material"),
                      const Text(
                        "See All",
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Card(
                          elevation: 6,
                          child: const Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        ),
                        const Card(
                          elevation: 6,
                          child: Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        ),
                        const Card(
                          elevation: 6,
                          child: Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        ),
                        const Card(
                          elevation: 6,
                          child: Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        ),
                        const Card(
                          elevation: 6,
                          child: Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        ),
                        const Card(
                          elevation: 6,
                          child: Icon(
                            Icons.abc,
                            size: 100,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
