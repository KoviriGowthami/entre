import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';
import '../home/HomeTabs.dart';

class ProfileImageEdit extends StatefulWidget {
  final String proPicture;
  const ProfileImageEdit({Key key, this.proPicture}) : super(key: key);

  @override
  State<ProfileImageEdit> createState() => _ProfileImageEditState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ProfileImageEditState extends State<ProfileImageEdit> {
  String filePath;
  AppState state;
  File imageFile;
  bool isInternetAvailable = true;

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
    ): Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(5),
          child: GestureDetector(
            child: Image.asset(
              "assets/images/back_btn3.png",
              width: 35,
              height: 35,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          "Profile Picture",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Myriad',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/body_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 300,
                width: 300,
                decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.proPicture),
                    fit: BoxFit.fill),),
            ),
          ],
        ),
      ),
    );
  }
  _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery,);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        uploadApi();
      });
    }
  }

  uploadApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiService.makeUploadApi(prefs.getString('userId'),imageFile.path).then((success) {
        var body = jsonDecode(success);
          final snackBar = SnackBar(
            content: Text(body['message']),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if(body['uploadImage'] == 'Image upload successfully'){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeTabs(),
            ),
                (route) => false,
          );
        }
    });
  }

}
