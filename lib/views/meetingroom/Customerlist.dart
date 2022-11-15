import 'dart:async';
import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BookMeetingRoom.dart';

class Customerlist extends StatefulWidget {
  const Customerlist({Key key}) : super(key: key);

  @override
  _Customerlist createState() => _Customerlist();
}

class _Customerlist extends State<Customerlist> {
  bool isChecked = false;
  List customerList = [];
  List SelectedCustomer = [];
  String selectedempid = "0";
  String selectedemp = " ";
  List searchResult = [];
  final TextEditingController _typeAheadController = TextEditingController();
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
    getCustomerList();
  }

  onselectedRow(bool selected, emp) {
    setState(() {
      if (selected) {
        setState(() {
          SelectedCustomer.add(emp);
        });
      } else {
        setState(() {
          SelectedCustomer.remove(emp);
        });
      }
    });
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
                    itemBuilder: (context, customerList) {
                      return ListTile(
                        onTap: () {
                          this._typeAheadController.text = customerList['customer'];
                          setState(() {
                            selectedempid = customerList['contactId'];
                            selectedemp = customerList['customer'];
                          });

                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        leading: Icon(
                          Icons.person_add,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        title: Text(customerList['customer'] +
                            '  (${customerList['contactId']})'),
                      );
                    },
                    onSuggestionSelected: (customerList) {},
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
                                'Customer id',
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            )),
                        DataColumn(
                            label: Expanded(
                              child: Text(
                                'Customer Name',
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            )),
                      ],
                      rows: customerList
                          .map(
                            (emp) => DataRow(
                            selected: SelectedCustomer.contains(emp),
                            onSelectChanged: (b) {
                              onselectedRow(b, emp);
                            },
                            cells: [
                              DataCell(
                                Text(emp['contactId']),
                              ),
                              DataCell(
                                Text(emp['customer']),
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
                    child:Image.asset('assets/images/savenew_btn.png',height: 30,),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BookMeetingRoom()));
                      Utilities.selectedcustomerList = SelectedCustomer;
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Container(
                  child: GestureDetector(
                    child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                    onTap: (){
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
      return customerList;
    } else {
      searchResult.clear();
      for (int i = 0; i < customerList.length; i++) {
        var data = customerList[i]['customer'];

        if (data.toLowerCase().contains(pattern.toLowerCase())) {
          searchResult.add(customerList[i]);
        }
      }
      return searchResult;
    }
  }

  getCustomerList() async {
    startTimer();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('CustomerList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        customerList = jsonDecode(data)['CustomerListDetails'];
        if (customerList.length < 0) {}
      }); // just printed length of data
    });
  }
}
