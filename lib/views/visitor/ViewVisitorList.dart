import 'dart:convert';

import 'package:entreplan_flutter/views/visitor/VisitorRegister.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';

class Visitor extends StatefulWidget {
  @override
  _VisitorState createState() => _VisitorState();
}

class _VisitorState extends State<Visitor> {
  bool isVisible = false;
  bool listVisible = false;
  List visitorList;
  void initState() {
    super.initState();
    getvisitorList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Visitor List"),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        elevation: 0.00,
        backgroundColor: Color(0xff2d324f),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: listVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: visitorList == null ? 0 : visitorList.length,
                    itemBuilder: (context, index) {
                      return VisitorsTile(
                          contactto: visitorList[index]['contact_to'],
                          id: visitorList[index]['id'],
                          names: visitorList[index]['names'],
                          vehiclenumber: visitorList[index]['vehicle_number'],
                          phone: visitorList[index]['mobile'],
                          members: visitorList[index]['members'],
                          address: visitorList[index]['address'],
                          passids: visitorList[index]['pass_ids'],
                          userid: visitorList[index]['id']);
                    }),
              ),
            ),
            Visibility(
              visible: isVisible,
              child: Center(
                heightFactor: 1.5,
                child: Container(
                  child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final String body = jsonEncode({
            "contactto": "",
            "name": "",
            "vehicalnumber": "",
            "phone": "",
            "address": "",
            "members": "",
            "passids": "",
            "userid": "",
            "type": "new",
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VisitorRegister(
                        visitordetails: body.toString(),
                      )));
        },
        label: const Text('Add Visitor'),
        icon: const Icon(Icons.add),
        backgroundColor: Color(0xff2d324f),
      ),
    );
  }

  getvisitorList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('visitorsList',body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        visitorList = jsonDecode(data)['visitors_list'];
        if (visitorList.length == 0) {
          isVisible = true;
        } else {
          listVisible = true;
        }
      });
    });
  }
}

class VisitorsTile extends StatefulWidget {
  final String contactto;
  final String id;
  final String names;
  final String vehiclenumber;
  final String phone;
  final String address;
  final String members;
  final String passids;
  final String userid;

  const VisitorsTile({
    Key key,
    this.contactto,
    this.id,
    this.names,
    this.vehiclenumber,
    this.phone,
    this.address,
    this.passids,
    this.userid,
    this.members,
  }) : super(key: key);

  @override
  _VisitorTileState createState() => _VisitorTileState();
}

class _VisitorTileState extends State<VisitorsTile> {
  String statusName = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.only(top: 16, right: 16, left: 16),
        child: Card(
          color: Color(0xfff1f3f6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Column(
            children: <Widget>[
              ListTile(
                onTap: () {
                  final String body = jsonEncode({
                    "contactto": widget.contactto,
                    "name": widget.names,
                    "vehiclenumber": widget.vehiclenumber,
                    "phone": widget.phone,
                    "address": widget.address,
                    "members": widget.members,
                    "passids": widget.passids,
                    "userid": widget.userid,
                    "id": widget.id,
                    "type": "edit",
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VisitorRegister(
                                visitordetails: body,
                              )));
                },
                title: Text(
                  "\n Contact to: ${widget.contactto}\n\n Name : ${widget.names}  \n\n Vehicle number :  ${widget.vehiclenumber} \n\n "
                  "Phone:${widget.phone}\n\n Members:${widget.members} \n\n Passids:${widget.passids}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'avenir', ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
