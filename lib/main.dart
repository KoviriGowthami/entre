import 'dart:async';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:entreplan_flutter/views/leave/Leave.dart';
import 'package:entreplan_flutter/views/login/SplashScreen.dart';
import 'package:entreplan_flutter/views/myinfo/ContactDetails.dart';
import 'package:entreplan_flutter/views/ot/Overtime.dart';
import 'package:entreplan_flutter/views/permission/Permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'flutter_app_badger.dart';
import 'models/Launguage.dart';
import 'views/meetingroom/MeetingRoom.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main()  {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp()));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xff77cebb), // status bar color
  ));
  runApp(MyApp());
}

MaterialColor buildMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _appBadgeSupported = 'Unknown';
  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;
  @override
  initState() {
    super.initState();
    initPlatformState();
    _addBadge();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
  }
  initPlatformState() async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _appBadgeSupported = appBadgeSupported;
    });
  }

  //Color myHexColor =Color(0xff2d324f);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.mobile:
        Utilities.dataState = 'Mobile Online';
        break;
      case ConnectivityResult.wifi:
        Utilities.dataState = 'Wifi Online';
        break;
      case ConnectivityResult.none:
      default:
      Utilities.dataState = 'Connection lost';
    }
    return GetMaterialApp(
      title: "EntRePlan",
        home: new SplashScreen(),
        theme: ThemeData(
          primarySwatch: buildMaterialColor(Color(0xff61c5aa)),
        ),
        debugShowCheckedModeBanner: false,
        locale: Locale('en'),
        translations: Translate(),
        routes: <String, WidgetBuilder>{
          '/screen1': (BuildContext context) => new ListViewHome(),
          '/screen3': (BuildContext context) => new Leave(),
          '/screen4': (BuildContext context) => new Permission(),
          '/screen5': (BuildContext context) => new Overtime(),
          '/screen7': (BuildContext context) => new PersonalInfo(),
          '/screen8': (BuildContext context) => new MeetingRoomScreen(),
        });
  }

  void _addBadge() {
    FlutterAppBadger.updateBadgeCount(1);
  }

  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }
}

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}