import 'dart:async';
import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BookMeetingRoom.dart';

class Vendorlist extends StatefulWidget {
  const Vendorlist({Key key}) : super(key: key);

  @override
  _Vendorlist createState() => _Vendorlist();
}

class _Vendorlist extends State<Vendorlist> {
  List vendorList = [];
  List selectedvendorlist = [];
  final TextEditingController _typeAheadController = TextEditingController();
  String selectedempid = "0";
  String selectedemp = " ";
  List searchResult = [];
  bool loading = true;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 3), (t) {
      setState(() {
        loading = false; //set loading to false
      });
      t.cancel(); //stops the timer
    });
  }

  void initState() {
    super.initState();
    selectedvendorlist = [];
    getVendorList();
  }

  onSelectedRow(bool selected, emp) {
    if (selected) {
      setState(() {
        selectedvendorlist.add(emp);
      });
    } else {
      setState(() {
        selectedvendorlist.remove(emp);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: " Search...",
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return getfilteredLIst(pattern);
                    },
                    itemBuilder: (context, vendorList) {
                      return ListTile(
                        onTap: () {
                          this._typeAheadController.text =
                          vendorList['vendor_name'];
                          setState(() {
                            selectedempid = vendorList['id'];
                            selectedemp = vendorList['vendor_name'];
                          });

                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        leading: Icon(
                          Icons.person_add,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        title: Text(
                            vendorList['vendor_name'] + '  (${vendorList['id']})'),
                      );
                    },
                    onSuggestionSelected: (vendorList) {},
                  )),
              loading
                  ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    CircularProgressIndicator(
                      color: Color(0xff2d324f),
                      strokeWidth: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        "Loading...wait...",
                        style: TextStyle(
                            color: Color(0xff2d324f),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
                  : Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    child: DataTable(
                      columnSpacing: 10,
                      columns: [
                        DataColumn(
                            label: Expanded(
                              child: Text(
                                'Vendor id',
                              ),
                            )),
                        DataColumn(
                            label: Expanded(
                              child: Text(
                                'Vendor Name',
                              ),
                            )),
                      ],
                      rows: vendorList
                          .map(
                            (emp) => DataRow(
                            selected: selectedvendorlist.contains(emp),
                            onSelectChanged: (isSelected) {
                              onSelectedRow(isSelected, emp);
                            },
                            cells: [
                              DataCell(
                                Text(emp['id']),
                              ),
                              DataCell(
                                Text(emp['vendor_name']),
                              ),
                            ]),
                      )
                          .toList(),
                    ),
                  )),
            ],
          )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: GestureDetector(
                    child: Image.asset('assets/images/savenew_btn.png',height: 30),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BookMeetingRoom()));
                      Utilities.selectedvendorList = selectedvendorlist;
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Container(
                  child: GestureDetector(
                    child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                    onTap: ()async{
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getfilteredLIst(pattern) {
    if (pattern == "") {
      return vendorList;
    } else {
      searchResult.clear();
      for (int i = 0; i < vendorList.length; i++) {
        var data = vendorList[i]['vendor_name'];

        if (data.toLowerCase().contains(pattern.toLowerCase())) {
          searchResult.add(vendorList[i]);
        }
      }
      return searchResult;
    }
  }

  getVendorList() async {
    startTimer();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('SupplierList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        vendorList = jsonDecode(data)['SupplierListDetails'];
      }); // just printed length of data
    });
  }
}
