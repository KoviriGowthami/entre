import 'dart:convert';

ContactDetails contactDetailsFromJson(String str) => ContactDetails.fromJson(json.decode(str));

String contactDetailsToJson(ContactDetails data) => json.encode(data.toJson());

class ContactDetails {
  ContactDetails({
    this.status,
    this.message,
    this.contactDetails,
  });

  int status;
  String message;
  List<ContactDetail> contactDetails;

  factory ContactDetails.fromJson(Map<String, dynamic> json) => ContactDetails(
    status: json["status"],
    message: json["message"],
    contactDetails: List<ContactDetail>.from(json["contactDetails"].map((x) => ContactDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "contactDetails": List<dynamic>.from(contactDetails.map((x) => x.toJson())),
  };
}

class ContactDetail {
  ContactDetail({
    this.addStrt1,
    this.addStrt2,
    this.cityCode,
    this.counCode,
    this.empZipcode,
    this.empHmTelephone,
    this.empMobile,
    this.empWorkTelephone,
    this.empWorkEmail,
    this.empOthEmail,
  });

  String addStrt1;
  String addStrt2;
  String cityCode;
  String counCode;
  String empZipcode;
  String empHmTelephone;
  String empMobile;
  String empWorkTelephone;
  String empWorkEmail;
  String empOthEmail;

  factory ContactDetail.fromJson(Map<String, dynamic> json) => ContactDetail(
    addStrt1: json["add_strt1"],
    addStrt2: json["add_strt2"],
    cityCode: json["city_code"],
    counCode: json["coun_code"],
    empZipcode: json["emp_zipcode"],
    empHmTelephone: json["emp_hm_telephone"],
    empMobile: json["emp_mobile"],
    empWorkTelephone: json["emp_work_telephone"],
    empWorkEmail: json["emp_work_email"],
    empOthEmail: json["emp_oth_email"],
  );

  Map<String, dynamic> toJson() => {
    "add_strt1": addStrt1,
    "add_strt2": addStrt2,
    "city_code": cityCode,
    "coun_code": counCode,
    "emp_zipcode": empZipcode,
    "emp_hm_telephone": empHmTelephone,
    "emp_mobile": empMobile,
    "emp_work_telephone": empWorkTelephone,
    "emp_work_email": empWorkEmail,
    "emp_oth_email": empOthEmail,
  };
}
