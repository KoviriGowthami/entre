import 'dart:convert';

EmergencyContact emergencyContactFromJson(String str) => EmergencyContact.fromJson(json.decode(str));

String emergencyContactToJson(EmergencyContact data) => json.encode(data.toJson());

class EmergencyContact {
  EmergencyContact({
    this.status,
    this.message,
    this.emergencyContacts,
  });

  int status;
  String message;
  List<EmergencyContactElement> emergencyContacts;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    status: json["status"],
    message: json["message"],
    emergencyContacts: List<EmergencyContactElement>.from(json["emergencyContacts"].map((x) => EmergencyContactElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "emergencyContacts": List<dynamic>.from(emergencyContacts.map((x) => x.toJson())),
  };
}

class EmergencyContactElement {
  EmergencyContactElement({
    this.name,
    this.relationship,
    this.hmtelphne,
    this.mobile,
    this.wrktelphn,
  });

  String name;
  String relationship;
  String hmtelphne;
  String mobile;
  String wrktelphn;

  factory EmergencyContactElement.fromJson(Map<String, dynamic> json) => EmergencyContactElement(
    name: json["name"],
    relationship: json["relationship"],
    hmtelphne: json["hmtelphne"],
    mobile: json["mobile"],
    wrktelphn: json["wrktelphn"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "relationship": relationship,
    "hmtelphne": hmtelphne,
    "mobile": mobile,
    "wrktelphn": wrktelphn,
  };
}
