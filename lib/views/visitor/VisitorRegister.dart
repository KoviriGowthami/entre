import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/HomeTabs.dart';

class VisitorRegister extends StatefulWidget {
  final String visitordetails;

  VisitorRegister({Key key, @required this.visitordetails}) : super(key: key);

  @override
  _VisitorRegisterState createState() => _VisitorRegisterState();
}

class _VisitorRegisterState extends State<VisitorRegister> {
  final _formKey = GlobalKey<FormState>();
  bool isVisible = true;
  bool noneditVisible = false;
  final body = "";
  String _names = "";
  String _userid = "";
  String _vehicalNumber = "";
  String _phoneNumber = "";
  String _address = "";
  String _member = "";
  String _ids = "";
  String _status = "";
  String _message = "";
  String buttonName = "Check In";
  String visitorid = "";

  var names = TextEditingController();
  var userid = TextEditingController();
  var vehicalNumber = TextEditingController();
  var phoneNumber = TextEditingController();
  var address = TextEditingController();
  var numberVeichal = TextEditingController();
  var member = TextEditingController();
  var ids = TextEditingController();
  final TextEditingController _typeAheadController = TextEditingController();
  String selectedemp = "Contact To";
  List empList;
  String selectedempid = "0";
  List searchResult = [];

  void initState() {
    super.initState();
    setData();
    getallemployeelist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Visitors Management"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                new Visibility(
                  visible: !isVisible,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: TypeAheadField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _typeAheadController,
                                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: " Contact To"),
                                ),
                                suggestionsCallback: (pattern) async {
                                  return getfilteredLIst(pattern, empList);
                                },
                                itemBuilder: (context, empList) {
                                  return ListTile(
                                    onTap: () {
                                      this._typeAheadController.text = empList['emp_name'];
                                      setState(() {
                                        selectedempid = empList['emp_number'];
                                        selectedemp = empList['emp_name'];
                                      });
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    },
                                    leading: Icon(
                                      Icons.person_add,
                                      color: Colors.black,
                                      size: 20.0,
                                    ),
                                    title: Text(empList['emp_name'] + '  (${empList['emp_number']})'),
                                  );
                                },
                                onSuggestionSelected: (empList) {},
                              )),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              controller: names,
                              onChanged: ((String val) {
                                setState(() {
                                  _names = val;
                                });
                              }),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: "Name",
                                  labelStyle: TextStyle(color: Colors.black)),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter name";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              controller: vehicalNumber,
                              onChanged: ((String value) {
                                setState(() {
                                  _vehicalNumber = value;
                                });
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.car_rental, color: Colors.black),
                                border: OutlineInputBorder(),
                                labelText: "Vehical Number",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter veichalnumber';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: phoneNumber,
                              onChanged: ((String value) {
                                setState(() {
                                  _phoneNumber = value;
                                });
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone_android, color: Colors.black),
                                border: OutlineInputBorder(),
                                labelText: "Phone Number",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                if (value.length < 10) {
                                  return 'phone number is too short';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              controller: address,
                              onChanged: ((String value) {
                                setState(() {
                                  _address = value;
                                });
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.location_city, color: Colors.black),
                                border: OutlineInputBorder(),
                                labelText: "Address",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: member,
                              onChanged: ((String value) {
                                setState(() {
                                  _member = value;
                                });
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.countertops_sharp,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(),
                                labelText: "member",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter members';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: ids,
                              onChanged: ((String value) {
                                setState(() {
                                  _ids = value;
                                });
                              }),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.supervisor_account,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(),
                                labelText: "Pass Ids",
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter id';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isVisible,
                  child: Column(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(10),
                          child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _typeAheadController,
                              enabled: false,
                              decoration: InputDecoration(border: OutlineInputBorder(), hintText: " Contact To"),
                            ),
                            suggestionsCallback: (pattern) async {
                              return;
                            },
                            itemBuilder: (context, empList) {
                              return ListTile(
                                onTap: () {
                                  this._typeAheadController.text = empList['emp_name'];
                                  setState(() {
                                    selectedempid = empList['emp_number'];
                                    selectedemp = empList['emp_name'];
                                  });
                                  FocusScope.of(context).requestFocus(FocusNode());
                                },
                                leading: Icon(
                                  Icons.person_add,
                                  color: Colors.black,
                                  size: 20.0,
                                ),
                                title: Text(empList['emp_name'] + '  (${empList['emp_number']})'),
                              );
                            },
                            onSuggestionSelected: (empList) {},
                          )),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          controller: names,
                          onChanged: ((String val) {
                            setState(() {
                              _names = val;
                            });
                          }),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(),
                              labelText: "Name",
                              labelStyle: TextStyle(color: Colors.black)),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          controller: vehicalNumber,
                          onChanged: ((String value) {
                            setState(() {
                              _vehicalNumber = value;
                            });
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.car_rental, color: Colors.black),
                            border: OutlineInputBorder(),
                            labelText: "Vehical Number",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter veichalnumber';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          keyboardType: TextInputType.phone,
                          controller: phoneNumber,
                          onChanged: ((String value) {
                            setState(() {
                              _phoneNumber = value;
                            });
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android, color: Colors.black),
                            border: OutlineInputBorder(),
                            labelText: "Phone Number",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (value.length < 10) {
                              return 'phone number is too short';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          controller: address,
                          onChanged: ((String value) {
                            setState(() {
                              _address = value;
                            });
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_city, color: Colors.black),
                            border: OutlineInputBorder(),
                            labelText: "Address",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter address';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.phone,
                          enabled: false,
                          controller: member,
                          onChanged: ((String value) {
                            setState(() {
                              _member = value;
                            });
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.countertops_sharp,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(),
                            labelText: "member",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter members';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          keyboardType: TextInputType.phone,
                          controller: ids,
                          onChanged: ((String value) {
                            setState(() {
                              _ids = value;
                            });
                          }),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.supervisor_account,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(),
                            labelText: "Pass Ids",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter id';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Color(0xff2d324f),
                      child: Text(
                        buttonName,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        if (buttonName == "Check In") {
                        if (_formKey.currentState.validate()) {
                          final String body = jsonEncode({
                            "contact_to": selectedempid.toString(),
                            "names": names.text.toString(),
                            "vehicle_number": vehicalNumber.text.toString(),
                            "phone": phoneNumber.text.toString(),
                            "address": address.text.toString(),
                            "members": member.text.toString(),
                            "pass_ids": ids.text.toString(),
                            "user_id": prefs.getString("userId")
                          });
                          ApiService.post('addVisitor',body).then((value) async {
                            final body = json.decode(value.body);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeTabs()));

                          });
                        }
                        } else {
                          final body = jsonEncode({"user_id": prefs.getString("userId"), "visitor_id": visitorid});
                          ApiService.post('checkOutVisitor',body).then((value) async {
                            final body = json.decode(value.body);
                            if (body['status'] == 1) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeTabs()));
                            }
                          });
                        }
                      }),
                )
              ],
            ),
          ),
        ));
  }

  getfilteredLIst(pattern, empList) {
    if (pattern == "") {
      return;
    } else {
      searchResult.clear();
      for (int i = 0; i < empList.length; i++) {
        var data = empList[i]['emp_name'];
        if (data.toLowerCase().contains(pattern.toLowerCase())) {
          searchResult.add(empList[i]);
        }
      }
      return searchResult;
    }
  }

  setData() {
    final body = json.decode(widget.visitordetails);
    if (body['type'] == "edit") {
      _typeAheadController.text = body['contactto'].toString();
      vehicalNumber.text = body['vehiclenumber'].toString();
      member.text = body['members'].toString();
      phoneNumber.text = body['phone'].toString();
      names.text = body['name'].toString();
      address.text = body['address'].toString();
      userid.text = body['userid'].toString();
      ids.text = body['passids'].toString();
      visitorid = body['id'].toString();
      buttonName = "Check Out";
      setState(() {
        isVisible = true;
      });
    } else {
      setState(() {
        isVisible = false;
      });
      return;
    }
  }

  getallemployeelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('employeeDetailsAll',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
      }); // just printed length of data
    });
  }
}
