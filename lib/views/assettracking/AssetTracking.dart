import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:entreplan_flutter/models/equipmentListModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../apiservice/rest_api.dart';

String id = "",
    equipment_id = "",
    title = "",
    assigned_to = "",
    start_date = "",
    start_time = "",
    end_dat = "",
    end_time = "",
    equipment_name = "",
    category_type_name = "",
    location_name = "",
    functional_location_name = "",
    plant_name = "",
    department_name = "",
    asset_number = "",
    cost_center_id = "",
    acquistn_value = "",
    acquistion_date = "",
    manufacturer = "",
    model_number = "",
    manufacturer_country = "",
    manufacturer_part_number = "",
    manufacturer_serial_number = "",
    reference_equipment_id = "",
    level = "",
    is_assembly = "",
    reportable = "";
Equipment list;

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode result;

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(flex: 4, child: _buildQrView(context)),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (result != null)
                      navigate(result.code)
                    else
                      Text('Scan a code'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                              onPressed: () async {
                                await controller?.toggleFlash();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getFlashStatus(),
                                builder: (context, snapshot) {
                                  return Text('Flash: ${snapshot.data}');
                                },
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                              onPressed: () async {
                                await controller?.flipCamera();
                                setState(() {});
                              },
                              child: FutureBuilder(
                                future: controller?.getCameraInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return Text('Camera facing ${describeEnum(snapshot.data)}');
                                  } else {
                                    return Text('loading');
                                  }
                                },
                              )),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },
                            child: Text('pause',),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.resumeCamera();
                            },
                            child: Text('resume',),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  navigate(result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('qrData', result);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCodeResult(
                  assetList: "",
                )));
  }
}

class QrCodeResult extends StatefulWidget {
  final String assetList;

  QrCodeResult({Key key, @required this.assetList}) : super(key: key);
  @override
  _QrCodeResultState createState() => _QrCodeResultState();
}

class _QrCodeResultState extends State<QrCodeResult> {
  void initState() {
    super.initState();
    service();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/all_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),
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
                    "Qr Result",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  alignment: Alignment.center,
                  child: Column(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Table(
                          columnWidths: {
                            0: FixedColumnWidth(150),
                            1: FlexColumnWidth(100),
                          },
                          textDirection: TextDirection.ltr,
                          defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                          border: TableBorder.all(width: 1.0, color: Colors.black),
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  " Name",
                                  textScaleFactor: 1.2,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(' $equipment_name', textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" Category", textScaleFactor: 1.2),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" $category_type_name", textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" Location", textScaleFactor: 1.2),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" $location_name", textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" Function", textScaleFactor: 1.2),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" $functional_location_name", textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" Plant", textScaleFactor: 1.2),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" $plant_name", textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(children: [
                              Padding(padding: EdgeInsets.all(10), child: Text(" Department", textScaleFactor: 1.2)),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(" $department_name", textScaleFactor: 1.2),
                              )
                            ]),
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(" StartDate", textScaleFactor: 1.2),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(" $start_date", textScaleFactor: 1.2),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(" Sighted", textScaleFactor: 1.2),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: ToggleSwitch(
                      initialLabelIndex: -1,
                      totalSwitches: 2,
                      labels: ['Yes', 'No'],
                      onToggle: (index) {
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(" Working", textScaleFactor: 1.2),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: ToggleSwitch(
                      initialLabelIndex: -1,
                      totalSwitches: 3,
                      labels: ['Yes', 'No', 'NA'],
                      onToggle: (index) {
                      },
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 50,right: 50,bottom: 20),
                child: RaisedButton(
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(40.0),
                  ),
                  color: Color(0xFF717171),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ));
  }

  service() async {
    final body = json.decode(widget.assetList);

    if (body['type'].toString() == "listdata") {
      25;
      equipment_name = body['title'].toString();
      category_type_name = body['category'].toString();
      functional_location_name = body['functionalLocationName'].toString();
      location_name = body['locationName'].toString();
      plant_name = body['plant'].toString();
      department_name = body['department_name'].toString();
    } else {
      ApiService.post('assignedEquipmentList',body).then((success) {
        final body = json.decode(success.body);
        if (body['assigned_equipment_list'].length > 0) {
          setState(() {
            id = body['assigned_equipment_list']["id"];
            equipment_id = body['assigned_equipment_list']["equipment_id"];
            title = body['assigned_equipment_list']["title"];
            assigned_to = body['assigned_equipment_list']["assigned_to"];
            start_date = body['assigned_equipment_list']["start_date"];
            start_time = body['assigned_equipment_list']["start_time"];
            end_dat = body['assigned_equipment_list']["end_dat"];
            end_time = body['assigned_equipment_list']["end_time"];
            equipment_name = body['assigned_equipment_list']["equipment_name"];
            category_type_name = body['assigned_equipment_list']["category_type_name"];
            location_name = body['assigned_equipment_list']["location_name"];
            functional_location_name = body['assigned_equipment_list']["functional_location_name"];
            plant_name = body['assigned_equipment_list']["plant_name"];
            department_name = body['assigned_equipment_list']["department_name"];
            asset_number = body['assigned_equipment_list']["asset_number"];
            cost_center_id = body['assigned_equipment_list']["cost_center_id"];
            acquistn_value = body['assigned_equipment_list']["acquistn_value"];
            acquistion_date = body['assigned_equipment_list']["acquistion_date"];
            manufacturer = body['assigned_equipment_list']["manufacturer"];
            model_number = body['assigned_equipment_list']["model_number"];
            manufacturer_country = body['assigned_equipment_list']["manufacturer_country"];
            manufacturer_part_number = body['assigned_equipment_list']["manufacturer_part_number"];
            manufacturer_serial_number = body['assigned_equipment_list']["manufacturer_serial_number"];
            reference_equipment_id = body['assigned_equipment_list']["reference_equipment_id"];
            level = body['assigned_equipment_list']["level"];
            is_assembly = body['assigned_equipment_list']["is_assembly"];
            reportable = body['assigned_equipment_list']["reportable"];
          });
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => QRViewExample()));
        }
      });
    }
  }
}
