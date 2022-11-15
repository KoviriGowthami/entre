import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/assettracking/AssetTracking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QrCode extends StatefulWidget {
  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  void initState() {
    super.initState();
    getequipmentList();
  }

  List equipmentList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/all_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 30),
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: GestureDetector(
                  child: Image.asset(
                    "assets/images/back_btn.png",
                    width: 20,
                    height: 20,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                width: 100,
              ),
              Text(
                "Assets List",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Myriad',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 70,
              ),
              IconButton(
                icon: Icon(
                  Icons.qr_code_scanner_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  // do something
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QRViewExample()));
                },
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: equipmentList == null ? 0 : equipmentList.length,
            itemBuilder: (context, index) {
              return EquipmentListTile(
                  title: equipmentList[index]['name'],
                  category: equipmentList[index]['category_type_name'],
                  locationName: equipmentList[index]['location_name'],
                  functionalLocationName: equipmentList[index]
                      ['functional_location_name'],
                  plant: equipmentList[index]['plant_name'],
                  departmentName: equipmentList[index]['department_name']);
            },
          ),
        ],
      ),
    ));
  }

  getequipmentList() async {
    final body = jsonEncode({"user_id": 14});
    ApiService.post('assignedToEmployeeEquipmentList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        equipmentList = jsonDecode(data)['assigned_emp_equipment_list'];
      });
    });
  }
}

class EquipmentListTile extends StatefulWidget {
  final String title;
  final String category;
  final String locationName;
  final String functionalLocationName;
  final String plant;
  final String departmentName;

  EquipmentListTile(
      {this.title,
      this.category,
      this.locationName,
      this.functionalLocationName,
      this.plant,
      this.departmentName});

  @override
  _EquipmentListTileState createState() => _EquipmentListTileState();
}

class _EquipmentListTileState extends State<EquipmentListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/asset_card.png"),
              fit: BoxFit.fill,
            ),
          ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(20,0, 20, 10),
      child: Column(
        children: <Widget>[
          Column(children: <Widget>[
                    Column(
                      children: [
                        Text("Equipment Name",
                            style:
                                TextStyle(fontFamily: 'Myriad',color: Colors.white)),
                        Text("${widget.title}",
                            style:
                                TextStyle(fontFamily: 'Myriad',color: Colors.white)),
                        SizedBox(height: 10,),
                        Text(
                          "\nCategory           :      ${widget.category} "
                          "\nLocation           :      ${widget.locationName} "
                          "\nFunction           :      ${widget.functionalLocationName}"
                          "\nPlant                 :      ${widget.plant} "
                          "\nDepartment     :       ${widget.departmentName}",
                          style: TextStyle(
                            fontFamily: 'Myriad',
                          ),
                        )
                      ],
                    ),
                Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image:
                                  AssetImage("assets/images/approve_btn.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: RaisedButton(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () {
                              final String body = jsonEncode({
                                "title": widget.title,
                                "category": widget.category,
                                "locationName": widget.locationName,
                                "functionalLocationName":
                                    widget.functionalLocationName,
                                "plant": widget.plant,
                                "department_name": widget.departmentName,
                                "type": "listdata"
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrCodeResult(
                                            assetList: body.toString(),
                                          )));
                            },
                            child: Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Myriad',
                              ),
                            ),
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    )),
              ])
        ],
      ),
    ));
  }
}
