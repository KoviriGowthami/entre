import 'dart:convert';
import 'dart:io';

import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/models/ContactDetails.dart';
import 'package:entreplan_flutter/models/EmergencyDetailsModel.dart';
import 'package:entreplan_flutter/models/detailsModel.dart';
import 'package:entreplan_flutter/views/myinfo/EditProfileImage.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../home/HomeTabs.dart';

class PersonalInfo extends StatefulWidget {

  @override
  _PersonalInfoState createState() => new _PersonalInfoState();
}

Utilities _utilities;

enum AppState {
  free,
  picked,
  cropped,
}

class _PersonalInfoState extends State<PersonalInfo> {
  String filePath;
  AppState state;
  File imageFile;
  String name = '';
  String dob = '';
  String profileimge = "";
  String empRole = " ";
  String fatherName = '',
      motherName = '',
      empPAnCardId = '',
      emp_uan_num = '',
      emp_dri_lice_exp_date = '',
      emp_pf_num = '',
      emp_dri_lice_num = '',
      blood_group = '',
      emp_hobbies = '',
      nation_code = '',
      emp_gender = '',
      emp_marital_status = '',
      emp_birthday = '';

  String emerName = '',
      relationship = '',
      hmtelphne = '',
      mobile = '',
      wrktelphn = '',
      emerName2 = '',
      relationship2 = '',
      hmtelphne2 = '',
      mobile2 = '',
      wrktelphn2 = '';

  String addStreet1 = '',
      add_strt2 = '',
      city_code = '',
      coun_code = '',
      emp_zipcode = '',
      emp_hm_telephone = '',
      emp_mobile = '',
      emp_work_telephone = '',
      emp_work_email = '',
      emp_oth_email = '';
  bool isInternetAvailable = true;


  void initState() {
    loadJson();
    loadContactDetails();
    loadEmergencyDetails();
    loadpersonalDetails();
    super.initState();
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
          "Profile",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontFamily: 'Myriad',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/body_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child:Column(
                  children: [
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        GestureDetector(
                          onTap:(){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileImageEdit(proPicture: profileimge,)));
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  image: DecorationImage(
                                      image: NetworkImage(profileimge),
                                      fit: BoxFit.fill),
                                  borderRadius: BorderRadius.all(Radius.circular(75.0)),
                                  boxShadow: [
                                    BoxShadow(blurRadius: 7.0, color: Colors.green)
                                  ]),
                            child: Container(
                              margin: EdgeInsets.only(left: 65,top: 65),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  tooltip: 'Upload Profile photo',
                                  icon: Icon(
                                    Icons.camera_enhance_sharp,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    _uploadAlert();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width/15,
                        ),
                        Column(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                fontWeight: FontWeight.bold,
                              ),),
                            SizedBox(height: 5,),
                            Text(
                              empRole,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 320,
                height: MediaQuery.of(context).size.height*0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      ExpandableNotifier(
                          child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/myinfo_card.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              ScrollOnExpand(
                                scrollOnExpand: true,
                                scrollOnCollapse: true,
                                child: ExpandablePanel(
                                  theme: const ExpandableThemeData(
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: true,
                                    hasIcon: false,
                                  ),
                                  header: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Personal Details",
                                            style: TextStyle(
                                                fontFamily: 'Myriad',
                                                color: Color(0xFF1c9324)),
                                          ),
                                          SizedBox(
                                            width: 150,
                                          ),
                                          Image.asset(
                                              "assets/images/down_arrow.png",
                                              height: 10,
                                              width: 10),
                                        ],
                                      )),
                                  collapsed: Row(
                                    children: [
                                      Text(
                                        'Name: ',
                                        style: TextStyle(
                                            fontFamily: 'Myriad',
                                            fontWeight: FontWeight.bold),
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      ),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: 'Myriad',
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      )
                                    ],
                                  ),
                                  expanded: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      for (var _ in Iterable.generate(1))
                                        Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Father Name : ',
                                                  style: TextStyle(
                                                      fontFamily: 'Myriad',
                                                      fontWeight: FontWeight.bold),
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                ),
                                                Text(
                                                  fatherName,
                                                  style: TextStyle(
                                                    fontFamily: 'Myriad',
                                                  ),
                                                  softWrap: true,
                                                  overflow: TextOverflow.fade,
                                                )
                                              ],
                                            )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Mother Name : ',
                                                style: TextStyle(
                                                    fontFamily: 'Myriad',
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                motherName,
                                                style: TextStyle(
                                                  fontFamily: 'Myriad',
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'PAN Number : ',
                                                style: TextStyle(
                                                    fontFamily: 'Myriad',
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                empPAnCardId,
                                                style: TextStyle(
                                                  fontFamily: 'Myriad',
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'UAN Number : ',
                                                style: TextStyle(
                                                    fontFamily: 'Myriad',
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                emp_uan_num,
                                                style: TextStyle(
                                                  fontFamily: 'Myriad',
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'PF Number : ',
                                                style: TextStyle(
                                                    fontFamily: 'Myriad',
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                emp_pf_num,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Blood Group : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                blood_group,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Hobbies : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                emp_hobbies,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Nationality : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                nation_code,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Driving License Number : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                emp_dri_lice_num,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                  builder: (_, collapsed, expanded) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: Expandable(
                                        collapsed: collapsed,
                                        expanded: expanded,
                                        theme: const ExpandableThemeData(
                                            crossFadePoint: 0),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      ExpandableNotifier(
                          child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/myinfo_card.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              ScrollOnExpand(
                                scrollOnExpand: true,
                                scrollOnCollapse: true,
                                child: ExpandablePanel(
                                  theme: const ExpandableThemeData(
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: true,
                                    hasIcon: false,
                                  ),
                                  header: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Emergency Contacts",
                                            style:
                                                TextStyle(color: Color(0xFF1c9324)),
                                          ),
                                          SizedBox(
                                            width: 125,
                                          ),
                                          Image.asset(
                                              "assets/images/down_arrow.png",
                                              height: 10,
                                              width: 10),
                                        ],
                                      )),
                                  collapsed: Row(
                                    children: [
                                      Text(
                                        'Person One : ',
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      ),
                                      Text(
                                        emerName,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      )
                                    ],
                                  ),
                                  expanded: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      for (var _ in Iterable.generate(1))
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Relationship : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                relationship,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Telephone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              hmtelphne,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Mobile Phone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              mobile,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Working Telephone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              wrktelphn,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Person Two : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emerName2,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Home Telephone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              hmtelphne2,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Mobile Phone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              mobile2,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Working Telephone2 : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              wrktelphn2,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  builder: (_, collapsed, expanded) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: Expandable(
                                        collapsed: collapsed,
                                        expanded: expanded,
                                        theme: const ExpandableThemeData(
                                            crossFadePoint: 0),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      ExpandableNotifier(
                          child: Padding(
                        padding: const EdgeInsets.all(10),
                        child:  Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/myinfo_card.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              ScrollOnExpand(
                                scrollOnExpand: true,
                                scrollOnCollapse: true,
                                child: ExpandablePanel(
                                  theme: const ExpandableThemeData(
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: true,
                                    hasIcon: false,
                                  ),
                                  header: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Contacts Details",
                                            style:
                                                TextStyle(color: Color(0xFF1c9324)),
                                          ),
                                          SizedBox(
                                            width: 147,
                                          ),
                                          Image.asset(
                                              "assets/images/down_arrow.png",
                                              height: 10,
                                              width: 10),
                                        ],
                                      )),
                                  collapsed: Row(
                                    children: [
                                      Text(
                                        'Location : ',
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                      ),
                                      Text(
                                        addStreet1,
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.fade,
                                        textDirection: TextDirection.ltr,
                                        textScaleFactor: 0.7,
                                      )
                                    ],
                                  ),
                                  expanded: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      for (var _ in Iterable.generate(1))
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                'Address Line : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                add_strt2,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                              )
                                            ],
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'City : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              city_code,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Zip/Postal Code : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_zipcode,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Home Telephone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_hm_telephone,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Mobile : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_mobile,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Work Telephone : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_work_telephone,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Work Email : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_work_email,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Other Email : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              emp_work_email,
                                              softWrap: true,
                                              overflow: TextOverflow.fade,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  builder: (_, collapsed, expanded) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 10),
                                      child: Expandable(
                                        collapsed: collapsed,
                                        expanded: expanded,
                                        theme: const ExpandableThemeData(
                                            crossFadePoint: 0),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  loadpersonalDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.get("userId")});
    ApiService.post('persnlDetails',body).then((success) {
      MyInfoModel loginModel = myInfoModelFromJson(success.body);

      setState(() {
        name = loginModel.persnlDetails[0].empName;
        fatherName = loginModel.persnlDetails[0].fatherName == null
            ? '--'
            : loginModel.persnlDetails[0].fatherName;
        motherName = loginModel.persnlDetails[0].motherName == null
            ? '--'
            : loginModel.persnlDetails[0].motherName;
        empPAnCardId = loginModel.persnlDetails[0].empPancardId == null
            ? '--'
            : loginModel.persnlDetails[0].empPancardId;
        emp_uan_num = loginModel.persnlDetails[0].empUanNum == null
            ? '--'
            : loginModel.persnlDetails[0].empUanNum;
        emp_pf_num = loginModel.persnlDetails[0].empPfNum == null
            ? '--'
            : loginModel.persnlDetails[0].empPfNum;
        emp_dri_lice_num = loginModel.persnlDetails[0].empDriLiceNum == null
            ? '--'
            : loginModel.persnlDetails[0].empDriLiceNum;
        emp_dri_lice_exp_date =
            loginModel.persnlDetails[0].empDriLiceExpDate == null
                ? '--'
                : loginModel.persnlDetails[0].empDriLiceExpDate;
        blood_group = loginModel.persnlDetails[0].bloodGroup == null
            ? '--'
            : loginModel.persnlDetails[0].bloodGroup;
        emp_hobbies = loginModel.persnlDetails[0].empHobbies == null
            ? '--'
            : loginModel.persnlDetails[0].empHobbies;
        nation_code = loginModel.persnlDetails[0].nationCode == null
            ? '--'
            : loginModel.persnlDetails[0].nationCode;
        emp_gender = loginModel.persnlDetails[0].empGender == null
            ? '--'
            : loginModel.persnlDetails[0].empGender;
        emp_marital_status =
            loginModel.persnlDetails[0].empMaritalStatus == null
                ? '--'
                : loginModel.persnlDetails[0].empMaritalStatus;
        emp_birthday = loginModel.persnlDetails[0].empBirthday == null
            ? '---'
            : loginModel.persnlDetails[0].empBirthday;
      });
    });
  }

  loadEmergencyDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.get("userId")});
    ApiService.post('emergencyContacts',body).then((success) {
      EmergencyContact loginModel = emergencyContactFromJson(success.body);
      setState(() {

        emerName = loginModel.emergencyContacts[0].name;
        relationship = loginModel.emergencyContacts[0].relationship;
        hmtelphne = loginModel.emergencyContacts[0].hmtelphne;
        mobile = loginModel.emergencyContacts[0].mobile;
        wrktelphn = loginModel.emergencyContacts[0].wrktelphn;
        emerName2 = loginModel.emergencyContacts[1].name;
        relationship2 = loginModel.emergencyContacts[0].relationship;
        hmtelphne2 = loginModel.emergencyContacts[0].hmtelphne;
        mobile2 = loginModel.emergencyContacts[0].mobile;
        wrktelphn2 = loginModel.emergencyContacts[0].wrktelphn;
      });
    });
  }

  loadContactDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.get("userId")});
    ApiService.post('contactDetails',body).then((success) {
      ContactDetails loginModel = contactDetailsFromJson(success.body) as ContactDetails;
      setState(() {
        addStreet1 = loginModel.contactDetails[0].addStrt1;
        add_strt2 = loginModel.contactDetails[0].addStrt2;
        city_code = loginModel.contactDetails[0].cityCode;
        coun_code = loginModel.contactDetails[0].counCode;
        emp_zipcode = loginModel.contactDetails[0].empZipcode;
        emp_hm_telephone = loginModel.contactDetails[0].empHmTelephone;
        emp_mobile = loginModel.contactDetails[0].empMobile;
        emp_work_telephone = loginModel.contactDetails[0].empWorkTelephone;
        emp_work_email = loginModel.contactDetails[0].empWorkEmail;
        emp_oth_email = loginModel.contactDetails[0].empOthEmail;
      });
    });
  }

  clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('islogin');
    await prefs.remove('stepcount');
  }

  loadJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empRole = prefs.getString("role");
      name = prefs.getString("empName");
      profileimge = prefs.getString("Proimage");
    });
    final body = jsonEncode({"user_id": int.parse(prefs.getString('userId'))});
    ApiService.post('persnlDetails',body).then((success) {
      MyInfoModel loginModel = myInfoModelFromJson(success.body);
      prefs.setString('detailss', success.body);
      setState(() {
        if(prefs.getString("empName").toString()!=loginModel.persnlDetails[0].empName) {
          name = loginModel.persnlDetails[0].empName;
          dob = loginModel.persnlDetails[0].empBirthday;
          profileimge = loginModel.persnlDetails[0].empPicture;
        }
      });
    });
  }

  _pickImagefromGallery() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery,);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        Navigator.pop(context);
        uploadApi();
      });
    }else{
      Navigator.pop(context);
    }
  }

  _pickImagefromCamera() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera,);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        Navigator.pop(context);
        uploadApi();
      });
    }else{
      Navigator.pop(context);
    }
  }

  _uploadAlert() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Photo!",
        ),
        content: Container(
          height: 100,
          width: 50,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              GestureDetector(
                  child:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Take Photo"),
                  ),
                  onTap:(){
                    _pickImagefromCamera();
                  }
              ),

              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Choose From Gallery"),
                ),
                onTap: () {
                 _pickImagefromGallery();
                },
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Cancel"),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  uploadApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ApiService.makeUploadApi(prefs.getString('userId'),imageFile.path).then((success) {
      var body = jsonDecode(success);
      final snackBar = SnackBar(
        content: Text('Image uploaded successfully'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if(body['uploadImage'] == 'Image upload successfully'){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeTabs()));
      }
    });
  }

}
