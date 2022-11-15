import 'dart:convert';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';
import '../../models/detailsModel.dart';
import '../dashboards/homedashboard.dart';
import '../login/LogInScreen.dart';
import '../myinfo/ContactDetails.dart';
import '../update_dialog.dart';

class HomeTabs extends StatefulWidget {

  const HomeTabs({Key key,   this.title}) : super(key: key);
  final String title;

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {

  final LocalAuthentication auth = LocalAuthentication();





  TextEditingController textEditingController = TextEditingController();
  final List<Map> locale = [
    {
      "text" : 'English',
      "locale" : Locale('en')
    },
    {
      "text" : 'తెలుగు',
      "locale" : Locale("tel")
    },
    {
      "text" : 'हिन्दी',
      "locale" : Locale("hi")
    },
  ];
  updateLanguage(Locale locale){
    Get.back();
    Get.updateLocale(locale);
  }

  bool isInternetAvailable = true;

  @override
  Alert(BuildContext context){
    return showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        alignment: Alignment.center,
        elevation: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: EdgeInsets.only(top: 10,bottom: 10),
              alignment: Alignment.center,
              color: Colors.greenAccent,
              child: Text("choose".tr),

            ),
            list(),
            RaisedButton(
                color: Colors.greenAccent,
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text("back".tr),
                onPressed: (){
                  Navigator.pop(context);
                })
          ],
        ),
      );
    });

  }


  Widget list(){
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context,int index){
          return Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            child: GestureDetector(
              child: Text(locale[index]["text"]),
              onTap: (){
                updateLanguage(locale[index]["locale"]);
              },
            ),
          );
        }, separatorBuilder: (context, index){
      return Container(
        alignment: Alignment.center,
        child: const Divider(
          color: Colors.black,
          indent: 10,
          endIndent: 10,
          thickness: 0.5,
        ),
      );
    },
        itemCount: locale.length);
  }
  String profileImg = "";
  String empName = "";

  // void checkNewVersion(NewVersion newVersion) async {
  //   final status = await newVersion.getVersionStatus();
  //   if(status.localVersion != status.storeVersion){
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return UpdateDialog(
  //           description: status.releaseNotes,
  //           version: status.storeVersion,
  //           appLink: status.appStoreLink,
  //         );
  //       },
  //     );
  //   }
  // }

  void _clearCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    setState(() {});
    getpersonalDetails();
  }


  void initState() {
    super.initState();
    _clearCache();
    getpersonalDetails();
    final newVersion = NewVersion(
        androidId:"com.entreplan_flutter"
    );
    newVersion.showAlertIfNecessary(context: Get.context);
    // checkNewVersion(newVersion);
  }

  void NewVersionUpdate(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
      if(status.canUpdate) {

    }
  }

  @override

  Widget build(BuildContext context) {
    if(Utilities.dataState=="Connection lost"){
      setState(() {
        isInternetAvailable = true;
      });
    }else{
      setState(() {
        isInternetAvailable = false;
      });
    }
    return isInternetAvailable?Scaffold(
      body: Center(
          heightFactor: 1,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child:  // Load a Lottie file from your assets
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child: Lottie.asset('assets/json/nointernet.json',fit: BoxFit.contain,height: 200,width: 200)),
                Container(
                  child: Text(
                    "No internet connection",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(30),
                  child: Text(
                    "You are not connected to the internet. Make sure Wi-Fi or Mobile data is on, Airplane Mode is Off and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    ):
    DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backwardsCompatibility: false,
          toolbarHeight: MediaQuery.of(context).size.height*0.12,
          title:Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PersonalInfo()));
                            },
                            child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(profileImg),
                                        fit: BoxFit.fill),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(75.0)),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 7.0,
                                          color: Colors.green)
                                    ])
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome".tr,
                                style: TextStyle(
                                  color: Color(0xFF006837),
                                  fontFamily: 'Myriad',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                width: 218,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: empName,
                                    hintStyle: TextStyle(
                                          color: Color(0xFF006837),
                                          fontFamily: 'Myriad',
                                          fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Image.asset(
                              "assets/images/lang_icon.png",
                              width: 50,
                              height: 50,
                            ),
                            onTap: () {
                              Alert(context);
                            },
                          ),
                          GestureDetector(
                            child: Image.asset(
                              "assets/images/exit_btn.png",
                              width: 50,
                              height: 50,
                            ),
                            onTap: () {
                              clearData();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LogInScreen()),
                                  ModalRoute.withName('/'));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white70,thickness: 1),
            ],
          ),
          bottom: TabBar(
            physics: NeverScrollableScrollPhysics(),
            isScrollable: false,
            tabs: <Widget>[
              Tab(
                child: Text(
                    "Dashboard".tr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Myriad',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Menu".tr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Myriad',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomeDashboard(),
            ListViewHome(),
          ],
        ),
      ),
    );
  }

  getpersonalDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImg = prefs.getString("Proimage");
      empName = prefs.getString("empName").toString();
    });
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('persnlDetails',body).then((success) {
      MyInfoModel loginModel = myInfoModelFromJson(success.body);
      prefs.setString('detailss', success.body);
      if(prefs.getString("Proimage").toString()!=loginModel.persnlDetails[0].empPicture) {
        setState(() {
          profileImg = loginModel.persnlDetails[0].empPicture;
          prefs.setString("Proimage", profileImg);
          empName = prefs.getString("empName").toString();
        });
      }
    });
  }


  clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('islogin');
    await prefs.remove('stepcount');
    await prefs.clear();
  }




}
