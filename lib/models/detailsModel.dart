import 'dart:convert';

MyInfoModel myInfoModelFromJson(String str) => MyInfoModel.fromJson(json.decode(str));

String myInfoModelToJson(MyInfoModel data) => json.encode(data.toJson());

class MyInfoModel {
  MyInfoModel({
    this.status,
    this.message,
    this.persnlDetails,
  });

  int status;
  String message;
  List<PersnlDetail> persnlDetails;

  factory MyInfoModel.fromJson(Map<String, dynamic> json) => MyInfoModel(
    status: json["status"],
    message: json["message"],
    persnlDetails: List<PersnlDetail>.from(json["persnlDetails"].map((x) => PersnlDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "persnlDetails": List<dynamic>.from(persnlDetails.map((x) => x.toJson())),
  };
}

class PersnlDetail {
  PersnlDetail({
    this.empName,
    this.fatherName,
    this.motherName,
    this.empPancardId,
    this.empUanNum,
    this.empPfNum,
    this.empDriLiceNum,
    this.empDriLiceExpDate,
    this.bloodGroup,
    this.empHobbies,
    this.nationCode,
    this.empGender,
    this.empMaritalStatus,
    this.empBirthday,
    this.empPicture,
  });

  String empName;
  String fatherName;
  String motherName;
  String empPancardId;
  String empUanNum;
  String empPfNum;
  String empDriLiceNum;
  dynamic empDriLiceExpDate;
  String bloodGroup;
  String empHobbies;
  String nationCode;
  String empGender;
  String empMaritalStatus;
  String empBirthday;
  String empPicture;

  factory PersnlDetail.fromJson(Map<String, dynamic> json) => PersnlDetail(
    empName: json["empName"],
    fatherName: json["fatherName"],
    motherName: json["motherName"],
    empPancardId: json["emp_pancard_id"],
    empUanNum: json["emp_uan_num"],
    empPfNum: json["emp_pf_num"],
    empDriLiceNum: json["emp_dri_lice_num"],
    empDriLiceExpDate: json["emp_dri_lice_exp_date"],
    bloodGroup: json["blood_group"],
    empHobbies: json["emp_hobbies"],
    nationCode: json["nation_code"],
    empGender: json["emp_gender"],
    empMaritalStatus: json["emp_marital_status"],
    empBirthday: json["emp_birthday"],
    empPicture: json["emp_picture"],
  );

  Map<String, dynamic> toJson() => {
    "empName": empName,
    "fatherName": fatherName,
    "motherName": motherName,
    "emp_pancard_id": empPancardId,
    "emp_uan_num": empUanNum,
    "emp_pf_num": empPfNum,
    "emp_dri_lice_num": empDriLiceNum,
    "emp_dri_lice_exp_date": empDriLiceExpDate,
    "blood_group": bloodGroup,
    "emp_hobbies": empHobbies,
    "nation_code": nationCode,
    "emp_gender": empGender,
    "emp_marital_status": empMaritalStatus,
    "emp_birthday": empBirthday,
    "emp_picture": empPicture,
  };
}
